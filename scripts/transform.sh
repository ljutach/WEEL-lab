#!/bin/bash

SAXON_JAR="tools/saxon-he-12.7.jar"
RESOLVER_JAR="tools/xmlresolver-5.2.0.jar"
VOWL_JAR="tools/webvowl/doc/Docker/OWL2VOWL-0.3.3-SNAPSHOT-shaded.jar"  # Updated path

INPUT="data/Ts-207_Clarino-pruned.xml"
XSLT="xslt/tei-to-html.xsl"
OUTPUT="index.html"
ONTOLOGY="rdf/wittgenstein_ontology.owl"
VOWL_JSON="tools/webvowl/src/app/data/wittgenstein.json"

# Run the transformation with both JARs
echo "🔄 Transforming $INPUT into $OUTPUT using $XSLT..."
java -cp "$SAXON_JAR:$RESOLVER_JAR" net.sf.saxon.Transform -s:"$INPUT" -xsl:"$XSLT" -o:"$OUTPUT"

if [ $? -eq 0 ]; then
  echo "✅ XSLT transformation complete. Output saved to $OUTPUT"

  # Now run the Python RDF generator
  echo "🧠 Generating RDF from TEI..."
  python3 scripts/tei_to_rdf.py

  if [ $? -eq 0 ]; then
    echo "✅ RDF generation complete. Saved to rdf/wittgenstein_output.ttl"

    # Convert OWL ontology to WebVOWL JSON
    echo "🌐 Converting OWL ontology to WebVOWL JSON..."
    java -jar "$VOWL_JAR" -file "$ONTOLOGY" > "$VOWL_JSON"

    if [ $? -eq 0 ]; then
      echo "✅ Conversion complete. JSON saved to $VOWL_JSON"
    else
      echo "❌ OWL to JSON conversion failed."
    fi

  else
    echo "❌ RDF generation failed."
  fi

else
  echo "❌ XSLT transformation failed. RDF and JSON not generated."
fi
