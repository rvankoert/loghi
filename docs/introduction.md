# Introduction

The Loghi framework is designed to streamline the process of Automatic Text Recognition (ATR), from analyzing document layouts to transcribing handwritten text into digital format. At the core of Loghi are three critical components, each responsible for a distinct aspect of the HTR pipeline:

## Laypa: Layout Analysis and Segmentation

[Laypa](https://github.com/knaw-huc/laypa/) specializes in the segmentation of documents, identifying different regions like paragraphs, page numbers, and most importantly, baselines within the text. Utilizing a sophisticated architecture based on a ResNet backbone and a feature pyramid network, Laypa performs pixel-wise classifications to detect these elements. Built on the [detectron2](https://github.com/facebookresearch/detectron2) framework, its output facilitates further processing by converting the classifications into instances—either as masks or directly into PageXML format. This segmentation is crucial for preparing documents for OCR/HTR processing, ensuring that text regions are accurately recognized and extracted.

## Loghi Tooling: Pre and Post-Processing Toolkit

The [Loghi Tooling](https://github.com/knaw-huc/loghi-tooling) module offers a suite of utilities designed to support the Loghi framework, handling tasks that occur both between and following the machine learning stages. This includes cutting images into individual text lines, integrating the transcription results into the PageXML, and recalculating reading orders among others. Its role is vital in managing the workflow of document preparation and finalization, streamlining the transition from raw image to processed text.

## Loghi HTR: Text Transcription

At the heart of the Loghi framework, the [Loghi HTR](https://github.com/knaw-huc/loghi-htr) module is responsible for the actual transcription of text from images. This system is not limited to handwritten text, as it is also capable of processing machine-printed text. By converting line images into textual data, Loghi HTR forms the final step in the HTR process, bridging the gap between visual data and usable digital text.

## How Loghi works 
Together, these components form a comprehensive ecosystem for handling HTR tasks, from initial layout analysis to the final transcription of text. The Loghi framework provides a flexible pipeline, and here is a generalized workflow to guide your usage:

1. **Baseline Detection:** Use Laypa to identify text baselines and regions in your documents, preparing them for HTR.

2. **Image Preprocessing:** If needed, preprocess images to enhance text recognition accuracy, such as line extraction and image normalization.

3. **Handwritten Text Recognition (HTR):** Process the prepared images through Loghi HTR to transcribe the text.

4. **Post-processing:** Apply necessary post-processing steps, such as merging HTR results into PageXML format, recalculating reading order, and splitting text into words.

To sum up, the Loghi framework offers a modular approach, allowing users to engage with individual components based on their specific needs, while also providing a cohesive solution for end-to-end handwritten text recognition. The approach also allows users to also utilize other PageXML based frameworks for different steps. As such it is possible to use Transkribus for layout analysis and Loghi HTR for text transcription, or Laypa for layout analysis and Kraken for text transcription. As long as the input and output is PageXML it should be possible to mix and match different tools.