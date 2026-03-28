# Understanding Loghi Output

After Loghi is run on your documents, the results are saved in PageXML format. This page explains how to read and understand the output.

## What is PageXML?

PageXML is an XML-based format for storing document layout and text transcription information. It's widely used in document analysis and handwritten text recognition projects. Loghi uses the **PageXML 2013-07-15 schema** for its output.

The PageXML files contain:
- Document metadata (image size, creator, etc.)
- Layout information (regions, text lines, baselines)
- Transcribed text content
- Confidence scores for predictions
- Coordinate information for all detected elements

## File Location

After running Loghi, you'll find the PageXML output in a `page/` subdirectory within your image directory. For example, if you process two images placed in the folder `/home/user/images`, you will see:

```
/home/user/images/
├── image1.jpg
├── image2.jpg
└── page/
    ├── image1.xml
    ├── image1.png
    ├── image2.xml
    └── image2.png
```

Each image has a corresponding XML file with the same name. Loghi also creates PNG files containing segmentation masks and baseline visualizations for each processed image.

## PageXML Structure

PageXML files are organized hierarchically:

```
PcGts (root)
└── Page
    ├── TextRegion (multiple)
    │   └── TextLine (multiple)
    │       ├── Baseline
    │       ├── Coords (bounding box)
    │       ├── TextEquiv (transcription)
    │       └── Word (multiple, if split)
    └── ReadingOrder (optional)
```

### Key Elements

**Page**: the top-level container representing the entire document page
- Contains the image filename and dimensions

**TextRegion**: a region of text on the page (e.g., a paragraph, column)
- Has coordinates defining its boundary
- Can have a type (e.g., "paragraph", "heading")

**TextLine**: a single line of text
- Contains the actual transcription
- Includes baseline coordinates (the line the text sits on)
- Has a bounding box (Coords)

**Baseline**: the line that text characters sit on
- Stored as a series of x,y coordinate points
- Used by HTR models for text extraction

**TextEquiv**: contains the transcribed text
- Includes a confidence score
- The actual text is in the `<Unicode>` tag

**Word**: individual words within a text line (if word splitting is enabled)
- Each word has its own coordinates and transcription

## Viewing PageXML

Several tools can visualize PageXML alongside the original images:

- **Transkribus**: Desktop application for viewing and editing transcriptions
- **PAGE Viewer**: Lightweight viewer for PageXML files
- **eScriptorium**: Web-based platform supporting PageXML import