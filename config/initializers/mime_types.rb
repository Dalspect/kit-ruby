# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf

Mime::Type.register "text/markdown", :markdown, [], %w(md mkd)
Mime::Type.register "application/msword", :doc
Mime::Type.register "application/vnd.openxmlformats-officedocument.wordprocessingml.document", :docx
