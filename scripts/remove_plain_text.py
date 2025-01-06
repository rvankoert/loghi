import os
import xml.etree.ElementTree as ET
import argparse


def remove_plain_text_from_element(parent):
    for element in list(parent):
        print(element.tag)
        if element.tag =="{http://schema.primaresearch.org/PAGE/gts/pagecontent/2013-07-15}PlainText":
            parent.remove(element)
        else:
            remove_plain_text_from_element(element)

def remove_plain_text_from_pagexml(directory):
    ET.register_namespace('', 'http://schema.primaresearch.org/PAGE/gts/pagecontent/2013-07-15')
    for filename in os.listdir(directory):
        if filename.endswith(".xml"):
            filepath = os.path.join(directory, filename)
            tree = ET.parse(filepath)
            root = tree.getroot()

            remove_plain_text_from_element(root)

            # Write the modified XML back to the file
            tree.write(filepath, encoding="utf-8")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Remove PlainText elements from PageXML files.")
    parser.add_argument("--path", metavar='path', type=str, help="Path to the directory containing PageXML files", required=True)
    args = parser.parse_args()

    remove_plain_text_from_pagexml(args.path)