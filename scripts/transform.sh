#!/bin/bash

SAXON_JAR="tools/saxon-he-12.7.jar"
RESOLVER_JAR="tools/xmlresolver-5.2.0.jar"

INPUT="data/Ts-207_Clarino-pruned.xml"
XSLT="xslt/tei-to-html.xsl"
OUTPUT="index.html"

# Run the transformation with both JARs
echo "🔄 Transforming $INPUT into $OUTPUT using $XSLT..."
java -cp "$SAXON_JAR:$RESOLVER_JAR" net.sf.saxon.Transform -s:"$INPUT" -xsl:"$XSLT" -o:"$OUTPUT"

if [ $? -eq 0 ]; then
  echo "✅ Transformation complete. Output saved to $OUTPUT"
else
  echo "❌ Transformation failed."
fi
