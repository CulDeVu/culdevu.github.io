
I've written a PNG decoder and a zip DEFLATE decoder on two separate occasions, one of which was used for the PNG decoding. This is to say that I know basically nothing about image compression. 

Starting out, I'm mostly interested in byte-based compression, not bit-based. I'm also only going to be working with the luminance channel for now. Each image is 1024x1024, so we're looking at 8388608 bits with no compression. I'm mostly interested in compression and transformations that can be done in parallel via SIMD or GPGPUs easily, and computations that can be done using `u8` arithmatic, or arithmatic on Z/256Z. I'm also mostly interested in lossless compression.

Finding the histogram and the entropy of the pixels gives:

- base entropy iq: 8069412
- base entropy squiggles: 7841410
- base entropy xp_pipes: 7618695

Which means that, if I was to just concat the pixel histogram with the arithmetically coded pixel values (assuming that the histogram could be represented in 8 bits per bin without loss of efficiency) we'd get 8071460, 7843458, 7620743 resp, achieving 0.96, 0.93, 0.91 percent file sizes with just that step. Zip files will sometimes contain embedded (themselves compressed) huffman tables, so this isn't that weird.

Here are the histograms:

[images]

Now the basis of all of the image and video compression techniques I know about is that pixels nearby are more similar than pixels far away. I wonder how true that is? Let's graph pairs of adjacent pixels.

```
// pairs entropy
int histo[256][256] = {0};
for (int i = 0; i < width*height; i += 2) {
  histo[data[i]][data[i+1]] += 1;
}
double entropy = 0;
int max_histo = 0;
for (int p = 0; p < 256; ++p)
for (int i = 0; i < 256; ++i) {
  if (histo[i][p] > 0) entropy += histo[i][p] * -log2((double)histo[i][p] / (width*height/2));
  if (histo[i][p] > max_histo) max_histo = histo[i][p];
}
printf("entropy: %f\n", entropy);

u8 *out_img = malloc(1024*1024*3);
memset(out_img, 0, 1024*1024*3);
FILE *fout = fopen("out.ppm", "wb");
fprintf(fout, "P6\n1024 1024 255\n");
for (int py = 0; py < 256; ++py)
for (int px = 0; px < 256; ++px) {
  double f = (double)histo[px][py] / (max_histo);
  int bar_x = px*4;
  int bar_y = py*4;
  for (int y = bar_y; y < bar_y+4; ++y)
  for (int x = bar_x; x < bar_x+4; ++x) {
    out_img[(y*1024 + x)*3 + 0] = 0x00;
    out_img[(y*1024 + x)*3 + 1] = 0xff*f;
    out_img[(y*1024 + x)*3 + 2] = 0x00;
  }
}
fwrite(out_img, 1, 1024*1024*3, fout);
```

[image comparisons]

Huh, well that's pretty conclusive, I'd say. The middle and last are hard to see because there are a couple small areas of pixels that are saturated to white. They're fairly small, but there's enough area to them that they totally dominate the histogram. Just for giggles, here's the the same histograms, but where every bin stores that bin's entropy.

[images]

And here's one where it's just plotting the differences between pixels, with 0 centered.

[images]

That code snippet also calculates the entropy of entire pixel pairs:

- pairs entropy iq: 5903458
- pairs entropy squiggles: 6643549
- pairs entropy pipes: 6353101

This is pretty nice. Doing the same as last time, encoding pairs of bytes and storing them along with the pairs-of-bytes-histogram, isn't *that* bad as of yet, it's still a win. But it won't be when we go up to quads of pixels, since the table is now `256*256*8=524288` bits, or 64KB. The one-dimensional histogram, for reference, was 256B. For quads of pixels, the histogram would be 4GB. We'll get back to that later.

But we're not there yet. So what would happen if I just transformed every pixel into the difference between it and its neighbor? That's still a reversable transformation.

```
// running difference
for (int y = height-1; y >= 1; y -= 1) {
  for (int x = 0; x < width; ++x) {
    data[y*width + x] = (data[y*width + x] - data[(y-1)*width + x]);
  }
}
for (int x = width-1; x >= 1; x -= 1) {
  data[x+1] = (data[x+1] - data[x]);
}
int histo[256] = {0};
for (int i = 0; i < width*height; i += 1) {
  histo[data[i]] += 1;
}
double entropy = {0};
for (int i = 0; i < 256; ++i) {
  if (histo[i] > 0) entropy += histo[i] * -log2((double)histo[i] / (width*height));
}
printf("entropy: %f\n", entropy);
```

This code, from the bottom up, computes for each pixel the difference between it and the pixel immediately above it. For the top line it computes differences between each pixel and the one to its left. This is a brain-dead simple to decompress in SIMD, so that's a big win in my book.

- running difference iq: 4108178
- running difference squiggles: 5722964
- running difference xp_pipes: 5352603

Great! File sizes are nearly half the raw uncompressed size for iq.png, and around 70% for the other two. For reference, these single-channel pngs are sized 3652640, 5197448, 5140888 bits resp. So this very simple encoding within 5% of PNG's size, measured against the raw entropy compression of the image bytes. This isn't representative by any measure, but it is interesting.

No doubt this can be fiddled with, adding bits here or there to pick a better pixel to compare against. But as it stands this compressor is only taking into account one neighbor for each pixel, not a representation of what all of the other pixels around them look like as a whole. So for instance, saying "this block of 16x16 pixels are all smoothly transitioning colors from here to here" will probably be better than "encode a value of -1 for each pixel in this 16x16 block". This is probably a good direction to go in, I'd imagine. I mean, macroblock coding has to be popular for a good reason, right?

I want to go back to the pixel pairs for a second. Let's do the transformation `data[i+0], data[i+1] -> data[i+0], (data[i+1] - data[i+0])`. Taking the entropy of these pairs gives 5903458, 6643549, 6353101. This is exactly the entropy for the pairs untransformed, which is a good sanity check since that transformation is refersible. But just for shits and giggles, what would happen if I were to entropy encode every other byte separately?

```
// pairs separated
for (int i = 0; i < width*height; i += 2) {
  data[i+1] = (data[i+1] - data[i]);
}
int histo[256][2] = {0};
for (int i = 0; i < width*height; i += 1) {
  histo[data[i]][i%2] += 1;
}
double entropy[2] = {0};
for (int p = 0; p < 2; ++p)
for (int i = 0; i < 256; ++i) {
  // printf("%d\n", histo[i][p]);
  if (histo[i][p] > 0) entropy[p] += histo[i][p] * -log2((double)histo[i][p] / (width*height/2));
}
printf("entropy: %f %f = %f\n", entropy[0], entropy[1], entropy[0] + entropy[1]);
```

- pairs separated iq: 6014385
- pairs separated squiggles: 6727887
- pairs separated xp_pipes: 6471385

Woahhh. I have to admit, I didn't expect that. I expected the result to be far closer to the original base entropy result. But, thinking about it a little, it makes some sense. Say I'm taking an input of `1 1 2 2 1 1 2 2` and turning it into `1 0 2 0 1 0 2 0`. The entropy of adjacent pairs doesn't change because there's just as many `1 1`s in the first as there are `1 0`s in the second, etc. But the entropy of the pairs separated is less than the base entropy because we're going from an entropy of `4*0.5*log(0.5) + 4*0.5*log(0.5) = 8` to `(2*0.5*log(0.5) + 2*0.5*log(0.5)) + 4*1*log(1) = 4`.

In addition to the entropy win, there's also a win in the amount of histogram bits that will have to go in the file too. As said previously, at 8 bits per bucket of the pixel pairs histogram (at the moment I'm only thinking about storing the histograms uncompressed), we're looking at 64KB. With this method we're looking at a histogram size of 512B.

But the win I'm most interested in is the following: we have a very cheap and expandible method of generating histributions that have decent entropy, and a *lower bound* on the best entropy that this method is able to achieve. Because this pair separation method will never be able to get a lower entropy than the entropy of the pairs themselves, right? So I can know how far away I am from optimal, for an admittedly silly definition of optimal.

Here for the iq image, I'm 110927 bit away, about 13KB or around one tenth of a bit per pixel. So what else is to be done?

The classic transformation, `diff[i+0], diff[i+1] -> (diff[i+0] + diff[i+1])/2, (diff[i+0] - diff[i+1])/2` isn't reversable. Correcting this to gives

```
u8 mid = (data[i+0]>>2) + (data[i+1]>>2) + (data[i+0]&data[i+1]);
u8 a = (data[i+0] < data[i+1]) ? mid : (mid + 0x80);
u8 b = data[i+1] - data[i+0];
data[i+0] = a;
data[i+1] = b;
```

, which does a bit worse at 6090994, 6930048, 6749589. I tried another of a similar variety, 

```
```

which [TODO].

I was curious about what sorts of mappings I had missed. The mapping `data[i+0], data[i+1] -> data[i+0], data[i+0] - data[i+1]` is really simple, are there better ones?

I wrote a brute forcer that runs through all invertable linear maps.

```
double best_entropy = 100000000;
for (int a = 0; a < 256; ++a)
for (int b = 0; b < 256; ++b)
for (int c = 0; c < 256; ++c)
for (int d = 0; d < 256; ++d) {
  u8 det = ((u8)a * (u8)d - (u8)c * (u8)b);
  if (det%2 == 0) continue;
  
  int histo[256][2] = {0};
  for (int i = 0; i < width*height; i += 2) {
    u8 out0 = ((u8)a*data[i+0] + (u8)b*data[i+1]);
    u8 out1 = ((u8)c*data[i+0] + (u8)d*data[i+1]);
    histo[out0][0] += 1;
    histo[out1][1] += 1;
  }
  double entropy_split[2] = {0};
  for (int p = 0; p < 2; ++p)
  for (int i = 0; i < 256; ++i) {
    if (histo[i][p] > 0) entropy_split[p] += histo[i][p] * -log2((double)histo[i][p] / (width*height/2));
  }
  double entropy = entropy_split[0] + entropy_split[1];
  if (entropy < best_entropy) {
    best_entropy = entropy;
    printf("%f\n", best_entropy);
    printf("%d %d %d %d\n", a, b, c, d);
  }
}
```

I let in run for like an hour before realizing I never set `-O3`, I was just running a debug build. And then a minute later I accidentally killed the process when trying to copy something from the terminal window lmao. It only got to the matrix `[ 0 49; 115 141 ]` before it was killed, and in that time it found the `[ 0 1; 1 -1 ]` matrix from before, and a handful of other matricies whose measured entropy was equal to it up to 6 decimal places.

I tried writing a more general brute forcer, but all it tried to do is something like this:

[image]

Not very helpful.

Just for shits and giggles, I tried the classic orthogonal square wave decomposition `data[i+0], data[i+1] -> data[i+0] + data[i+1], data[i+0] - data[i+1]`. It's not reversible, but who knows? I do, it's 6090554, 6963846, 6775737, not the greatest.

I tried to come up with an enumeration of all the different kinds of mappings that are continuous, but couldn't come up with anything usefully different that what I have.

Let's look at quads now. They're interesting.

So the combinatorics on the size of the histogram for full quads is real real bad. If done like earlier, the histogram would need `2^40` bits. BUT in a 1024x1024 image, there are only `2^18` 2x2 pixel quads, coming out to `2^26` bits or 256KB maximum to store them all. A bit much, but it's good to remember that it's an option.

I measured the entropy of each image's quads:

- quad entropy iq: 4075245
- quad entropy quiggles: 4549141
- quad entropy xp_pipes: 4443075

Wow, awesome! These numbers are better than our previously best numbers, the running differences. Of course, this can't be used as-is because of the histogram storage problem. But our trick of finding a good transformation of the bytes and entropy encoding them separately might do the trick.

Trying 

```
for (int i = 0; i < width*height; i += 4) {
  data[i+1] = (data[i+1] - data[i]);
  data[i+2] = (data[i+2] - data[i]);
  data[i+3] = (data[i+3] - data[i]);
}
// base entropy
int histo[256][4] = {0};
for (int i = 0; i < width*height; i += 1) {
  histo[data[i]][i%4] += 1;
}
double entropy[4] = {0};
for (int p = 0; p < 4; ++p)
for (int i = 0; i < 256; ++i) {
  if (histo[i][p] > 0) entropy[p] += histo[i][p] * -log2((double)histo[i][p] / (width*height/4));
}
printf("entropy: %f %f %f %f = %f\n", entropy[0], entropy[1], entropy[2], entropy[3], entropy[0] + entropy[1] + entropy[2] + entropy[3]);
```

- quad separated 1 iq: 5139228
- quad separated 1 squiggles: 6316631
- quad separated 1 xp_pipes: 6388895

Dissapointing. How about taking one of our known good pair mapping functions and apply them horizontally to both rows, and then vertically to both columns.

```
for (int y = 0; y < height; y += 2)
for (int x = 0; x < width; x += 2) {
  data[(y+0)*width + (x+1)] = (data[(y+0)*width + (x+1)] - data[(y+0)*width + (x+0)]);
  data[(y+1)*width + (x+1)] = (data[(y+1)*width + (x+1)] - data[(y+1)*width + (x+0)]);
  
  data[(y+1)*width + (x+0)] = (data[(y+1)*width + (x+0)] - data[(y+0)*width + (x+0)]);
  data[(y+1)*width + (x+1)] = (data[(y+1)*width + (x+1)] - data[(y+0)*width + (x+1)]);
}
```

- quad separated 2 iq: 5013753
- quad separated 2 squiggles: 6095857
- quad separated 2 xp_pipes: 5912341

Okay that's a little better, but honestly I expected a lot more. 