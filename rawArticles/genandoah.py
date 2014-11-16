import mistune
import os
import shutil

WORKING_DIR = os.getcwd()
SOURCE_DIR = os.path.join(WORKING_DIR, 'source')
BUILD_DIR = os.path.join(WORKING_DIR, 'site')

def build_posts():
  files = [os.path.join(SOURCE_DIR, file) for file in os.listdir(SOURCE_DIR)]

  for file in files:
    post_name = os.path.splitext(os.path.basename(file))[0]

    markdown_post_file = open(file)
    markdown_post_text = markdown_post_file.read()

    html_post_file = open(os.path.join(BUILD_DIR, post_name + '.html'), 'w+')
    html_post_text = "<html><head><title>!!INSERT TITLE HERE!!!</title>" + \
      "<script src='../main.js'></script><script src='../latexit.js'></script></head><body>" + mistune.markdown(markdown_post_text) + "</body></html>"
    html_post_file.write(html_post_text)

    markdown_post_file.close()
    html_post_file.close()

def build_site():
  #if not os.path.isdir(BUILD_DIR):
  #    os.makedirs(BUILD_DIR)

  # Delete old build
  if os.path.isdir(BUILD_DIR):
    shutil.rmtree(BUILD_DIR)
  os.mkdir(BUILD_DIR)

  build_posts()

build_site()
