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
                <link rel="stylesheet">
                    <xsl:attribute name="href">../css/style.css</xsl:attribute>
                </link>
            </head>

            <body>
                <h1><xsl:value-of select="//tei:title"/></h1>
                <!-- <h1><xsl:value-of select="//tei:title[@type='main']"/></h1> -->
                <xsl:apply-templates select="//tei:teiHeader"/>
                <xsl:apply-templates select="//tei:body"/>
            </body>
        </html>
    </xsl:template>
    
    <!-- ========== TEI Header ========== -->
    <xsl:template match="tei:teiHeader">
        <section class="tei-header">
            <h2>Document Metadata</h2>
            <table class="metadata-table">

                <tr>
                    <th>Title</th>
                    <td><xsl:value-of select=".//tei:title[@type='WS']"/></td>
                </tr>
                <tr>
                    <th>Author</th>
                    <td><xsl:value-of select=".//tei:author/tei:persName"/></td>
                </tr>
                <tr>
                    <th>Editor(s)</th>
                    <td><xsl:apply-templates select=".//tei:editor"/></td>
                </tr>
                <tr>
                    <th>Funder(s)</th>
                    <td><xsl:value-of select=".//tei:funder"/></td>
                </tr>
                <tr>
                    <th>Publisher</th>
                    <td><xsl:value-of select=".//tei:publicationStmt/tei:publisher"/></td>
                </tr>
                <tr>
                    <th>Location</th>
                    <td><xsl:value-of select=".//tei:pubPlace"/></td>
                </tr>
                <tr>
                    <th>Source</th>
                    <td><xsl:value-of select=".//tei:sourceDesc/tei:p"/></td>
                </tr>
                <tr>
                    <th>License</th>
                    <td><xsl:value-of select=".//tei:availability/tei:p"/></td>
                </tr>
                <tr>
                    <th>Subject</th>
                    <td><xsl:value-of select=".//tei:keywords/tei:term"/></td>
                </tr>
            </table>
        </section>
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
