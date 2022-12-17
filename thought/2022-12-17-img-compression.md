
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

This is pretty nice. Doing the same as last time, encoding pairs of bytes and storing them along with the pairs-of-bytes-histogram, isn't *that* bad as of yet, it's still a win. But it won't be when we go up to quads of pixels, since the table is now `256*256*8=524288` bits, or 65KB. The one-dimensional histogram, for reference, was 256B. For quads of pixels, the histogram would be 4GB. We'll get back to that later.

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

Woahhh. I have to admit, I didn't expect that. I expected the result to be far closer to the original base entropy result. But, thinking about it a little, it makes some sense. I'm taking an input of `1 1 2 2 1 1 2 2` and turning it into `1 0 2 0 1 0 2 0`. The entropy of adjacent pairs doesn't change because there's just as many `1 1`s in the first as there are `1 0`s in the second, etc. But the entropy of the pairs separated is less than the base entropy because we're going from a distribution of `0, 0.5, 0.5` to a distribution of `0.5, 0.25, 0.25`. Reductions of 