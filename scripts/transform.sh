#!/bin/bash

SAXON_JAR="tools/saxon-he-12.7.jar"
RESOLVER_JAR="tools/xmlresolver-5.2.0.jar"

INPUT="data/Ts-207_Clarino-pruned.xml"
XSLT="xslt/tei-to-html.xsl"
OUTPUT="index.html"

echo "🔄 Transforming $INPUT into $OUTPUT using $XSLT..."
java -cp "$SAXON_JAR:$RESOLVER_JAR" net.sf.saxon.Transform -s:"$INPUT" -xsl:"$XSLT" -o:"$OUTPUT"

if [ $? -eq 0 ]; then
  echo "✅ XSLT transformation complete. Output saved to $OUTPUT"

  echo "🧠 Generating RDF from TEI..."
  python3 scripts/tei_to_rdf.py

  if [ $? -eq 0 ]; then
    echo "✅ RDF generation complete. Saved to rdf/wittgenstein_output.ttl"
  else
    echo "❌ RDF generation failed."
  fi

else
  echo "❌ XSLT transformation failed. RDF not generated."
fi
