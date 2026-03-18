# intake/product — Product Documents

Drop files here to enrich your product context automatically.

## Supported file types
| Type | Extension | Example use |
|------|-----------|-------------|
| PDF | .pdf | Sales deck, one-pager, technical whitepaper |
| Word | .docx | Product spec, solution brief, internal wiki export |
| Markdown | .md | Product docs export, README, release notes |
| Text | .txt | Any copied content, email threads, Slack exports |
| CSV | .csv | Feature comparison matrix, integration list |
| JSON | .json | API schema, config examples |

## What to put here
- Sales decks and one-pagers
- Technical documentation
- Integration guides
- Competitive battle cards
- Internal product specs
- Customer case study documents
- Release notes / changelogs
- API reference docs (exported)

## How it works
When you run "Build a prompt" (option 2 from START menu), the tool
automatically reads all files in this folder and appends their content
to your product context — giving Claude richer, more specific information
to work with.

Files here SUPPLEMENT your PRODUCT_CONTEXT.md — they don't replace it.
The context file provides structure; these documents provide depth and detail.

## Tips
- You can drop in multiple files — all will be read
- File names don't matter, but descriptive names help you stay organised
- Remove outdated files when content is superseded
- For very large documents, the most relevant sections are most useful
