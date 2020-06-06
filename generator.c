#include <assert.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <windows.h>

typedef uint8_t u8;

int post_num = 0;
char *post_href[50] = {0};
char *post_names[50] = {0};
char *post_descr[50] = {0};

int thought_num = 0;
char *thought_href[50] = {0};
char *thought_names[50] = {0};
char *thought_descr[50] = {0};

char *resume = "As stated in the sidebar, I'm currently job-seeking. My resume can be found as a pdf link(resume/Daniel_Taylor_Resume_Jan_2019.pdf)[here] and also embeded using your browser's default pdf viewer below:\n\n<embed src=\"/resume/Daniel_Taylor_Resume_Jan_2019.pdf\" style=\"width: 100%; height:800px\" type=\"application/pdf\">";

void consume_whitespace(char **head)
{
	while (strlen(*head) > 0 && **head == ' ')
		*head += 1;
}

// NOTE: does not consume new line chars
char *consume_line(char **head)
{
	char *nl = *head;
	while (strlen(nl) > 0 && *nl != '\n' && *nl != '\r')
		++nl;

	char *line = calloc((nl - *head) + 1, 1);
	memcpy(line, *head, nl - *head);

	// Now kill off the remaining new line chars
	if (strlen(nl) > 0 && *nl == '\r')
		++nl;
	if (strlen(nl) > 0 && *nl == '\n')
		++nl;

	*head = nl;
	return line;
}

bool plain_text_mode = false;
void format_line(FILE *fout, char *line)
{
	while (strlen(line))
	{
		if (!strcmp(line, "$$"))
		{
			plain_text_mode = !plain_text_mode;
			line += 2;
			fprintf(fout, "$$");
		}
		else if (*line == '$')
		{
			plain_text_mode = !plain_text_mode;
			fprintf(fout, "%c", *line);
			++line;
		}
		else if (*line == '*' && !plain_text_mode)
		{
			fprintf(fout, "<i>");
			++line;
			while (strlen(line) && *line != '*')
			{
				fprintf(fout, "%c", *line);
				++line;
			}
			fprintf(fout, "</i>");
			++line;
		}
		else if (*line == '`' && !plain_text_mode)
		{
			fprintf(fout, "<tt>");
			++line;
			while (strlen(line) && *line != '`')
			{
				fprintf(fout, "%c", *line);
				++line;
			}
			fprintf(fout, "</tt>");
			++line;
		}
		else if (strlen(line) >= 4 && !memcmp(line, "img(", 4)) // images in the form img(link)[bottom text]
		{
			fprintf(fout, "<figure><img src=\"");
			line += 4;

			while (*line != ')')
			{
				fprintf(fout, "%c", *line);
				++line;
			}
			++line;
			assert(*line == '[');
			++line;
			fprintf(fout, "\" style=\"max-width:100%%\"><figcaption>");

			while (*line != ']')
			{
				fprintf(fout, "%c", *line);
				++line;
			}
			++line;

			fprintf(fout, "</figcaption></figure>");
		}
		else if (strlen(line) >= 7 && !memcmp(line, "imgcmp(", 7)) // side-by-side image comparison
		{
			// NOTE: this should be improved in the future. Currently the images being compared don't go onto separate lines when the window width becomes too small to fit both images.
			fprintf(fout, "<table><tr style=\"vertical-align:top\"><td><figure style=\"margin:0\"><img src=\"");
			line += 7;

			while (*line != ')')
			{
				fprintf(fout, "%c", *line);
				++line;
			}
			++line;
			assert(*line == '[');
			++line;
			fprintf(fout, "\" style=\"width:100%%\"><figcaption>");

			while (*line != ']')
			{
				fprintf(fout, "%c", *line);
				++line;
			}
			++line;

			fprintf(fout, "</figcaption></figure></td>");

			// And now the second one
			fprintf(fout, "<td><figure style=\"margin:0\"><img src=\"");
			assert(*line == '(');
			++line;

			while (*line != ')')
			{
				fprintf(fout, "%c", *line);
				++line;
			}
			++line;
			assert(*line == '[');
			++line;
			fprintf(fout, "\" width=\"100%%\"><figcaption>");

			while (*line != ']')
			{
				fprintf(fout, "%c", *line);
				++line;
			}
			++line;

			fprintf(fout, "</figcaption></figure></td></tr></table>");
		}
		else if (strlen(line) >= 5 && !memcmp(line, "link(", 5)) // links in the form link(link)[bottom text]
		{
			fprintf(fout, "<a href=\"");
			line += 5;

			while (*line != ')')
			{
				fprintf(fout, "%c", *line);
				++line;
			}
			++line;
			assert(*line == '[');
			++line;
			fprintf(fout, "\">");

			while (*line != ']')
			{
				fprintf(fout, "%c", *line);
				++line;
			}
			++line;

			fprintf(fout, "</a>");
		}
		else
		{
			fprintf(fout, "%c", *line);
			++line;
		}
	}
}

void write_header(FILE *fout)
{
	FILE *f_template_in = fopen("../template.html", "rb");

	// Dump in the template html
	char c;
	while ((c = fgetc(f_template_in)) != EOF)
	{
		fputc(c, fout);
	}
}
void write_footer(FILE *fout)
{
	fprintf(fout, "</div><script src=\"https://polyfill.io/v3/polyfill.min.js?features=es6\"></script>\n<script id=\"MathJax-script\" async src=\"https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js\"></script><script>window.MathJax = { tex: { inlineMath: [['$', '$']] } };</script></body></html>");
}
void write_markdown(FILE *fout, char *buf, char **name, char **descr)
{
	write_header(fout);

	int line_num = 0;
	char *lines[1024];
	while (strlen(buf))
	{
		lines[line_num] = consume_line(&buf);
		// printf("%zd ", strlen(lines[line_num]));
		++line_num;
	}

	for (int i = 0; i < line_num; ++i)
	{
		char *line = lines[i];

		if (strlen(line) >= 2 && !memcmp(line, "===", 3)) // Description
		{
			line += 3;
			consume_whitespace(&line);

			// post_descr[post_num] = line;
			*descr = line;
		}
		else if (strlen(line) >= 2 && !memcmp(line, "==", 2)) // Title
		{
			line += 2;
			consume_whitespace(&line);

			// post_names[post_num] = line;
			*name = line;

			fprintf(fout, "<h2>%s</h2>", line);
		}
		else if (strlen(line) >= 1 && !memcmp(line, "#", 1)) // Headings
		{
			line += 1;
			consume_whitespace(&line);

			fprintf(fout, "<h3>%s</h3>", line);
		}
		else if (strlen(line) >= 3 && !memcmp(line, "```", 3)) // Code blocks
		{
			fprintf(fout, "<pre class=\"codeblock\"><code>");
			while (i < line_num - 1)
			{
				++i;
				line = lines[i];
				if (strlen(line) < 3 || memcmp(line, "```", 3))
				{
					fprintf(fout, "%s\n", line);
				}
				else
				{
					break;
				}
			}
			++i;
			fprintf(fout, "</code></pre>");
		}
		else if (strlen(line) == 0)
		{
			continue;
		}
		else if ((i == 0 || strlen(lines[i - 1]) == 0)) // Paragraph tags
		{
			fprintf(fout, "<p>");
			while (i < line_num && strlen(lines[i]) != 0)
			{
				format_line(fout, lines[i]);
				++i;
			}
			fprintf(fout, "</p>");
		}
		else
		{
			
		}
		// printf("%zd %s\n", strlen(line), line);
		// printf("STRLEN BUF %lld\b", strlen(buf));
	}

	write_footer(fout);
}

void process_post(char *name)
{
	char *in_name = calloc(strlen(name) + 100, 1);
	sprintf(in_name, "../post/%s.md", name);

	FILE *fin = fopen(in_name, "rb");

	char *out_name = calloc(strlen(name) + 100, 1);
	sprintf(out_name, "../post/%s/index.html", name);
	FILE *fout = fopen(out_name, "w");

	char *out_href = calloc(strlen(name) + 100, 1);
	sprintf(out_href, "/post/%s/", name);
	post_href[post_num] = out_href;

	fseek(fin, 0, SEEK_END);
	int size = ftell(fin);
	rewind(fin);

	char *buf = calloc(size + 1, 1);
	fread(buf, 1, size, fin);
	fclose(fin);

	write_markdown(fout, buf, &post_names[post_num], &post_descr[post_num]);

	post_num += 1;
}

void process_thought(char *name)
{
	char *in_name = calloc(strlen(name) + 100, 1);
	sprintf(in_name, "../thought/%s.md", name);

	FILE *fin = fopen(in_name, "rb");

	char *out_name = calloc(strlen(name) + 100, 1);
	sprintf(out_name, "../thought/%s/index.html", name);
	FILE *fout = fopen(out_name, "w");

	char *out_href = calloc(strlen(name) + 100, 1);
	sprintf(out_href, "/thought/%s/", name);
	thought_href[thought_num] = out_href;

	fseek(fin, 0, SEEK_END);
	int size = ftell(fin);
	rewind(fin);

	char *buf = calloc(size + 1, 1);
	fread(buf, 1, size, fin);
	fclose(fin);

	write_markdown(fout, buf, &thought_names[thought_num], &thought_descr[thought_num]);

	thought_num += 1;
}

int main()
{
	process_post("2018-08-12-nopelepsy-03");
	process_post("2016-02-02-microfacet-dummies");

	process_thought("2020-06-06-jvm-sucks");

	{
		FILE *fout = fopen("../index.html", "w");
		write_header(fout);
		for (int i = 0; i < post_num; ++i)
		{
			fprintf(fout, "<h2><a href=\"%s\">%s</a></h2><p>%s</p>", post_href[i], post_names[i], post_descr[i]);
		}
		write_footer(fout);
	}

	{
		FILE *fout = fopen("../thought/index.html", "w");
		write_header(fout);
		fprintf(fout, "<p>This is where I put much shorter pieces that are less informative and opinionated/inflamatory enough for me to not put on my front page.</p><hr>");
		for (int i = 0; i < thought_num; ++i)
		{
			fprintf(fout, "<h2><a href=\"%s\" class=\"primary_link\">%s</a></h2><p>%s</p>", thought_href[i], thought_names[i], thought_descr[i]);
		}
		write_footer(fout);
	}

	{
		FILE *fout = fopen("../resume/index.html", "w");
		write_markdown(fout, resume, NULL, NULL);
	}

	printf("end");
}