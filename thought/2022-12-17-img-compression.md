
I've written a PNG decoder and a zip DEFLATE decoder on two separate occasions, one of which was used for the PNG decoding. This is to say that I know basically nothing about image compression. 

Starting out, I'm mostly interested in byte-based compression, not bit-based. I'm also only going to be working with the luminance channel for now. Each image is 1024x1024, so we're looking at 8388608 bits with no compression

Finding the histogram and the entropy of the pixels gives:

- base entropy iq: 8069412
- base entropy squiggles: 7841410
- base entropy xp_pipes: 7618695

Which means that, if I was to just concat the pixel histogram with the arithmetically coded pixel values (assuming that the histogram could be represented in 8 bits per bin without loss of efficiency) we'd get 8071460, 7843458, 7620743 resp, achieving 0.96, 0.93, 0.91 percent file sizes with just that step.

Now the basis of all of the image and video compression techniques I know about is that pixels nearby are more similar than pixels far away. I wonder how true that is?

```
// pairs entropy
int histo[256][256] = {0};
for (int i = 0; i < width*height; i += 2) {
  // if (data[i] > 250 && data[i+1] > 250) continue;
  data[i+1] = (data[i+1] - data[i]) + 0x80;
  histo[data[i]][data[i+1]] += 1;
}
double entropy = 0;
int max_histo = 0;
for (int p = 0; p < 256; ++p)
for (int i = 0; i < 256; ++i) {
  printf("%d\n", histo[i][p]);
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

