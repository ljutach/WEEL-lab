<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="tei"
    version="3.0">
    
    <!-- Output HTML5 -->
    <xsl:output method="html" indent="yes" encoding="UTF-8" html-version="5"/>
    
    <!-- ========== Root Template ========== -->
    <xsl:template match="/">
        <html lang="en">
            <head>
                <meta charset="UTF-8"/>
                <title>
                    <xsl:value-of select="//tei:title"/>
                </title>
                <style>
                    body { font-family: sans-serif; max-width: 700px; margin: 2em auto; }
                    .name { font-weight: bold; color: darkblue; }
                    .place { color: darkgreen; }
                </style>
            </head>
            <body>
                <h1><xsl:value-of select="//tei:title"/></h1>
                <xsl:apply-templates select="//tei:body"/>
            </body>
        </html>
    </xsl:template>
    
    <!-- ========== Paragraphs ========== -->
    <xsl:template match="tei:p">
        <p><xsl:apply-templates/></p>
    </xsl:template>
    
    <!-- ========== Named Entities ========== -->
    <xsl:template match="tei:persName">
        <span class="name"><xsl:apply-templates/></span>
    </xsl:template>
    
    <xsl:template match="tei:placeName">
        <span class="place"><xsl:apply-templates/></span>
    </xsl:template>
    
    <xsl:template match="tei:name">
        <span class="name"><xsl:apply-templates/></span>
    </xsl:template>
    
    <!-- ========== Line Breaks ========== -->
    <xsl:template match="tei:lb">
        <br/>
    </xsl:template>
    
    <!-- ========== Fallback (for all other elements) ========== -->
    <xsl:template match="*">
        <xsl:apply-templates/>
    </xsl:template>
    
</xsl:stylesheet>
