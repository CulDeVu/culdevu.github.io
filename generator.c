#include <assert.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

typedef uint8_t u8;

int post_num = 0;
char *post_rss_date[50] = {0};
char *post_date[50] = {0};
char *post_href[50] = {0};
char *post_names[50] = {0};
char *post_descr[50] = {0};

int thought_num = 0;
char *thought_rss_date[50] = {0};
char *thought_date[50] = {0};
char *thought_href[50] = {0};
char *thought_names[50] = {0};
char *thought_descr[50] = {0};

char *resume = "I'm currently job-seeking. My resume can be found as a pdf link(/resume/Daniel_Taylor_Resume_Jec_2023.pdf)[here] and also embeded using your browser's default pdf viewer below. Last updated January 2023.\n\n<embed src=\"/resume/Daniel_Taylor_Resume_Jan_2023.pdf\" style=\"width: 100%; height:800px\" type=\"application/pdf\">";

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
		else if (strlen(line) >= 2 && !memcmp(line, "**", 2) && !plain_text_mode)
		{
			fprintf(fout, "<b>");
			line += 2;
			while (strlen(line) > 2 && memcmp(line, "**", 2))
			{
				fprintf(fout, "%c", *line);
				++line;
			}
			fprintf(fout, "</b>");
			line += 2;
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
			fprintf(fout, "<code class=\"codeinline\">");
			++line;
			while (strlen(line) && *line != '`')
			{
				fprintf(fout, "%c", *line);
				++line;
			}
			fprintf(fout, "</code>");
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
			fprintf(fout, "\" style=\"align-self: center; max-width:100%%\">");

			assert(*line == '[');
			++line;
			if (*line != ']')
			{
				// Only include a caption if there's a caption to write
				fprintf(fout, "<figcaption>");

				while (*line != ']')
				{
					fprintf(fout, "%c", *line);
					++line;
				}
				fprintf(fout, "</figcaption>");
			}
			++line;

			fprintf(fout, "</figure>");
		}
		else if (strlen(line) >= 7 && !memcmp(line, "imgcmp(", 7)) // side-by-side image comparison
		{
			// NOTE: this should be improved in the future. Currently the images being compared don't go onto separate lines when the window width becomes too small to fit both images.
			fprintf(fout, "<table><tr style=\"vertical-align:top\"><td width=50%%><figure><img src=\"");
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
			fprintf(fout, "<td><figure><img src=\"");
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
		else if (strlen(line) >= 5 && !memcmp(line, "img3(", 5)) // side-by-side image comparison
		{
			// NOTE: this should be improved in the future. Currently the images being compared don't go onto separate lines when the window width becomes too small to fit both images.
			fprintf(fout, "<table><tr style=\"vertical-align:top\">");
			line += 4;

			for (int i = 0; i < 3; ++i) {
				fprintf(fout, "<td width=33.333%%><figure><img src=\"");
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
				fprintf(fout, "\" style=\"width:100%%\"><figcaption>");

				while (*line != ']')
				{
					fprintf(fout, "%c", *line);
					++line;
				}
				++line;

				fprintf(fout, "</figcaption></figure></td>");
			}

			fprintf(fout, "</tr></table>");
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
	// TODO: on windows this inserts extra newline characters
	char c;
	while ((c = fgetc(f_template_in)) != EOF)
	{
		fputc(c, fout);
	}
}
void write_footer(FILE *fout)
{
	char *str = u8"</div><div style=\"background-color: #222; padding: 1em; color: #fafafa\">Written by Daniel Taylor.<br>Email: contact@djtaylor.me<br><br><span style=\"color: #aaa\">\u00a9 2024 by Daniel Taylor</span></div>";
	fwrite(str, 1, strlen(str), fout);
	fprintf(fout, "<script src=\"https://polyfill.io/v3/polyfill.min.js?features=es6\"></script>\n<script id=\"MathJax-script\" async src=\"/3rd-party/mathjax/tex-mml-chtml.js\"></script><script>window.MathJax = { tex: { inlineMath: [['$', '$']] } };</script></body></html>");
}
void write_markdown(FILE *fout, char *buf, char **name, char **descr, char *date)
{
	write_header(fout);

	int line_num = 0;
	char *lines[1024];
	while (strlen(buf))
	{
		lines[line_num] = consume_line(&buf);
		++line_num;
	}

	for (int i = 0; i < line_num; ++i)
	{
		char *line = lines[i];

		if (strlen(line) >= 3 && !memcmp(line, "===", 3)) // Description
		{
			line += 3;
			consume_whitespace(&line);

			*descr = line;
		}
		else if (strlen(line) >= 2 && !memcmp(line, "==", 2)) // Title
		{
			line += 2;
			consume_whitespace(&line);

			*name = line;

			fprintf(fout, "<h2 style=\"margin-bottom:0.5rem\">%s</h2><i>Pub. %s</i>", line, date);
		}
		else if (strlen(line) >= 2 && !memcmp(line, "##", 2)) // Headings
		{
			line += 2;
			consume_whitespace(&line);

			fprintf(fout, "<h4>%s</h3>", line);
		}
		else if (strlen(line) >= 1 && !memcmp(line, "#", 1)) // Headings
		{
			line += 1;
			consume_whitespace(&line);

			fprintf(fout, "<h3 class=\"section_heading\">%s</h3>", line);
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
		else if (strlen(line) >= 1 && !memcmp(line, ">", 1)) // Block quotes
		{
			line += 1;
			consume_whitespace(&line);

			fprintf(fout, "<blockquote>%s</blockquote>", line);
		}
		else if (strlen(line) >= 1 && !memcmp(line, "-", 1)) // Bullet points
		{
			fprintf(fout, "<ul>");
			while (i < line_num && strlen(lines[i]) != 0)
			{
				char *l = lines[i];
				l += 1;
				consume_whitespace(&l);

				fprintf(fout, "<li>");
				format_line(fout, l);
				fprintf(fout, "</li>");
				++i;
			}
			fprintf(fout, "</ul>");
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

char *month_table[12] = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};
void process_post(char *name)
{
	// Date
	{
		int year, month, day;
		sscanf(name, "%d-%d-%d", &year, &month, &day);

		char *tmp = calloc(200, 1);
		sprintf(tmp, "%d %s %d", year, month_table[month - 1], day);
		post_date[post_num] = tmp;

		tmp = calloc(200, 1);
		sprintf(tmp, "%02d %s %d 00:00:00 GMT", day, month_table[month - 1], year);
		post_rss_date[post_num] = tmp;
	}

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

	write_markdown(fout, buf, &post_names[post_num], &post_descr[post_num], post_date[post_num]);

	post_num += 1;
}

void process_thought(char *name)
{
	// Date
	{
		int year, month, day;
		sscanf(name, "%d-%d-%d", &year, &month, &day);

		char *tmp = calloc(200, 1);
		sprintf(tmp, "%d %s %d", year, month_table[month - 1], day);
		thought_date[thought_num] = tmp;

		tmp = calloc(200, 1);
		sprintf(tmp, "%02d %s %d 00:00:00 GMT", day, month_table[month - 1], year);
		thought_rss_date[thought_num] = tmp;
	}

	char *in_name = calloc(strlen(name) + 1024, 1);
	sprintf(in_name, "../thought/%s.md", name);

	FILE *fin = fopen(in_name, "rb");
	if (!fin)
	{
		printf("Could not open file %s", in_name);
	}

	char *out_name = calloc(strlen(name) + 1024, 1);
	sprintf(out_name, "../thought/%s/index.html", name);
	FILE *fout = fopen(out_name, "w");
	if (!fout)
	{
		printf("Count not open file %s", out_name);
	}

	char *out_href = calloc(strlen(name) + 1024, 1);
	sprintf(out_href, "/thought/%s/", name);
	thought_href[thought_num] = out_href;

	fseek(fin, 0, SEEK_END);
	int size = ftell(fin);
	rewind(fin);

	char *buf = calloc(size + 1, 1);
	fread(buf, 1, size, fin);
	fclose(fin);

	write_markdown(fout, buf, &thought_names[thought_num], &thought_descr[thought_num], thought_date[thought_num]);

	thought_num += 1;
}

int main()
{
	process_post("2022-07-08-nopelepsy-04");
	process_post("2022-05-20-mcci");
	process_post("2018-08-12-nopelepsy-03");
	process_post("2018-01-02-nopelepsy-02");
	process_post("2016-02-02-microfacet-dummies");

	process_thought("2023-09-06-logarithms");
	process_thought("2023-04-09-make");
	process_thought("2023-01-08-img-compression");
	process_thought("2023-01-07-china-bit");
	process_thought("2022-12-05-ffmpeg");
	process_thought("2022-05-06-shitty-ps2");
	process_thought("2021-10-22-mcci");
	process_thought("2021-06-16-chaos-engine");
	process_thought("2021-06-11-segment-register");
	process_thought("2021-06-04-x11-asm");
	process_thought("2021-02-06-u8-encoding");
	process_thought("2020-09-03-stack");
	process_thought("2020-08-05-sending-strings");
	process_thought("2020-07-17-units-typedefs");
	process_thought("2020-06-18-new-website");
	process_thought("2020-06-06-jvm-sucks");

	char *post_header = "<h2 style=\"margin-bottom:0.5rem\"><a href=\"%s\" class=\"primary_link\">%s</a></h2><i>Pub. %s</i>";

	{
		FILE *fout = fopen("../index.html", "w");
		write_header(fout);
		fprintf(fout, "<p>This is where longer pieces go where I talk about things I've been playing with in my spare time. I constantly have side projects, but I don't always feel like writing long pieces about them. These are posted very very rarely.</p><hr>");
		for (int i = 0; i < post_num; ++i)
		{
			fprintf(fout, post_header, post_href[i], post_names[i], post_date[i]);
			fprintf(fout, "<p style=\"margin-top: 0.5rem\">%s</p>", post_descr[i]);

			if (i != post_num - 1)
				fprintf(fout, "<hr>");
		}
		write_footer(fout);
	}

	{
		FILE *fout_finished = fopen("../thought/index.html", "w");
		write_header(fout_finished);
		fprintf(fout_finished, "<p>This is where I put much shorter pieces that are less informative and opinionated/inflamatory enough for me to not put on my front page. Unfinished posts are located <a href=\"/thought/wip.html\">here</a></p>");

		FILE *fout_wip = fopen("../thought/wip.html", "w");
		write_header(fout_wip);
		fprintf(fout_wip, "<p>This is where I put unfinished posts and notes about things to write about later.</p>");

		for (int i = 0; i < thought_num; ++i)
		{
			FILE *fout_dest = (strcmp(thought_descr[i], "wip") == 0) ? fout_wip : fout_finished;

			fprintf(fout_dest, "<hr>");

			fprintf(fout_dest, post_header, thought_href[i], thought_names[i], thought_date[i]);
			fprintf(fout_dest, "<p style=\"margin-top: 0.5rem\">%s</p>", thought_descr[i]);
		}
		write_footer(fout_finished);
		write_footer(fout_wip);
	}

	{
		FILE *fout = fopen("../resume/index.html", "w");
		write_markdown(fout, resume, NULL, NULL, NULL);
	}

	{
		FILE *fin = fopen("../portfolio/portfolio.md", "rb");
		fseek(fin, 0, SEEK_END);
		int size = ftell(fin);
		rewind(fin);

		char *buf = calloc(size + 1, 1);
		fread(buf, 1, size, fin);
		fclose(fin);

		FILE *fout = fopen("../portfolio/index.html", "w");
		write_markdown(fout, buf, NULL, NULL, NULL);
	}

	// RSS feed
	{
		FILE *fout = fopen("../feed.xml", "w");
		// TODO: lastBuildDate tag
		fprintf(fout, "<rss version=\"2.0\"><channel><title>djtaylor.me</title><link>http://djtaylor.me</link><description>Daniel Taylor's blog</description>");

		for (int i = 0; i < post_num; ++i)
		{
			fprintf(fout, "<item><title>%s</title><link>%s</link><pubDate>%s</pubDate><description>%s</description></item>", post_names[i], post_href[i], post_rss_date[i], post_descr[i]);
		}

		for (int i = 0; i < thought_num; ++i)
		{
			if (strcmp(thought_descr[i], "wip") != 0)
			{
				fprintf(fout, "<item><title>%s</title><link>%s</link><pubDate>%s</pubDate><description>%s</description></item>", thought_names[i], thought_href[i], thought_rss_date[i], thought_descr[i]);
			}
		}

		fprintf(fout, "</channel></rss>");
	}

	printf("end");
}
