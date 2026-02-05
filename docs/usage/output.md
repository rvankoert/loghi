# Understanding Loghi Output

<!-- content created by copilot, needs to be proofread-->

After running Loghi on your documents, the results are saved in PageXML format. This page explains how to read and understand the output files.

## What is PageXML?

PageXML is an XML-based format for storing document layout and text transcription information. It's widely used in document analysis and handwritten text recognition projects. Loghi uses the **PageXML 2013-07-15 schema** for its output.

The PageXML files contain:
- Document metadata (image size, creator, etc.)
- Layout information (regions, text lines, baselines)
- Transcribed text content
- Confidence scores for predictions
- Coordinate information for all detected elements

## File Location

After running Loghi, you'll find the PageXML output in a `page/` subdirectory within your image directory:

```
your-images/
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

**Page**: The top-level container representing the entire document page
- Contains the image filename and dimensions

**TextRegion**: A region of text on the page (e.g., a paragraph, column)
- Has coordinates defining its boundary
- Can have a type (e.g., "paragraph", "heading")

**TextLine**: A single line of text
- Contains the actual transcription
- Includes baseline coordinates (the line the text sits on)
- Has a bounding box (Coords)

**Baseline**: The line that text characters sit on
- Stored as a series of x,y coordinate points
- Used by HTR models for text extraction

**TextEquiv**: Contains the transcribed text
- Includes a confidence score
- The actual text is in the `<Unicode>` tag

**Word**: Individual words within a text line (if word splitting is enabled)
- Each word has its own coordinates and transcription

## Example PageXML

Here's a simplified example:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<PcGts xmlns="http://schema.primaresearch.org/PAGE/gts/pagecontent/2013-07-15">
  <Metadata>
    <Creator>Loghi HTR</Creator>
    <Created>2026-02-05T12:00:00</Created>
  </Metadata>
  <Page imageFilename="example.jpg" imageWidth="2000" imageHeight="3000">
    <TextRegion id="region_1" type="paragraph">
      <Coords points="100,200 1900,200 1900,400 100,400"/>
      
      <TextLine id="line_1">
        <Coords points="100,200 1900,200 1900,250 100,250"/>
        <Baseline points="100,240 1900,240"/>
        <TextEquiv conf="0.95">
          <Unicode>This is the transcribed text from the first line.</Unicode>
        </TextEquiv>
      </TextLine>
      
      <TextLine id="line_2">
        <Coords points="100,260 1900,260 1900,310 100,310"/>
        <Baseline points="100,300 1900,300"/>
        <TextEquiv conf="0.89">
          <Unicode>Here is the second line of text.</Unicode>
        </TextEquiv>
      </TextLine>
    </TextRegion>
  </Page>
</PcGts>
```

## Understanding Coordinates

Coordinates in PageXML are specified as pairs of x,y values in pixels, with the origin (0,0) at the top-left corner of the image.

**Coords points**: Define a polygon boundary (usually a rectangle)
- Format: `"x1,y1 x2,y2 x3,y3 x4,y4"`
- For rectangles: typically top-left, top-right, bottom-right, bottom-left

**Baseline points**: Define the baseline as a series of points
- Format: `"x1,y1 x2,y2 ... xn,yn"`
- Can be a straight line or follow the curve of the text

## Confidence Scores

The `conf` attribute in `TextEquiv` indicates the model's confidence in the transcription:
- Range: 0.0 (no confidence) to 1.0 (complete confidence)
- Higher values indicate more reliable transcriptions
- Use this to identify lines that may need manual review

:::{tip}
Lines with confidence below 0.7 often contain errors and should be reviewed manually.
:::

## Viewing and Editing PageXML

### Viewing Tools

Several tools can visualize PageXML alongside the original images:

- **Transkribus**: Desktop application for viewing and editing transcriptions
- **PAGE Viewer**: Lightweight viewer for PageXML files
- **eScriptorium**: Web-based platform supporting PageXML import

### Programmatic Access

You can also process PageXML files programmatically using Python:

```python
import xml.etree.ElementTree as ET

# Parse the PageXML file
tree = ET.parse('page/image1.xml')
root = tree.getroot()

# Define namespace
ns = {'page': 'http://schema.primaresearch.org/PAGE/gts/pagecontent/2013-07-15'}

# Extract all text lines
for line in root.findall('.//page:TextLine', ns):
    text_elem = line.find('.//page:Unicode', ns)
    if text_elem is not None:
        print(text_elem.text)
```

## Reading Order

PageXML can include a `ReadingOrder` element that specifies the sequence in which text regions should be read. This is especially useful for documents with complex layouts (multiple columns, mixed text and images, etc.).

The reading order is represented as ordered groups and references to region IDs:

```xml
<ReadingOrder>
  <OrderedGroup id="reading_order_1">
    <RegionRefIndexed index="0" regionRef="region_1"/>
    <RegionRefIndexed index="1" regionRef="region_2"/>
  </OrderedGroup>
</ReadingOrder>
```

## Next Steps

Now that you understand the PageXML output format, you can:
- Extract text for further processing
- Calculate accuracy metrics by comparing with ground truth
- Train custom models using your corrected transcriptions
- Integrate Loghi output into your document processing pipeline

For more advanced usage, see:
- [Training Custom Models](training)
- [Web Service API](webservice)
