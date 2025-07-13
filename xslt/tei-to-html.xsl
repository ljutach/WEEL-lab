<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="tei"
    version="3.0">
    
    <xsl:output method="html" indent="yes" encoding="UTF-8" html-version="5"/>
    
    <!-- Root Template -->
    <xsl:template match="/">
        <html lang="en">
            <head>
                <meta charset="UTF-8"/>
                <title><xsl:value-of select="//tei:title[@type='WS']"/></title>
                <link rel="stylesheet" href="css/style.css"/>
            </head>
            <body>
                <nav class="navbar">
                    <ul>
                        <li><a href="documentation.html">Documentation</a></li>
                        <li><a href="http://example.org:8890/sparql" target="_blank">SPARQL Endpoint</a></li>
                    </ul>
                </nav>
                <h1><xsl:value-of select="//tei:title[@type='WS']"/></h1>
                <xsl:apply-templates select="//tei:teiHeader"/>
                <xsl:apply-templates select="//tei:body"/>
            </body>
        </html>
    </xsl:template>
    
    <!-- TEI Header -->
    <xsl:template match="tei:teiHeader">
        <section class="tei-header">
            <h2>Document Metadata</h2>
            <table class="metadata-table">
                <tr><th>Title</th><td><xsl:value-of select=".//tei:title[@type='WS']"/></td></tr>
                <tr><th>Author</th><td><xsl:value-of select=".//tei:author/tei:persName"/></td></tr>
                <tr><th>Editor(s)</th><td><xsl:apply-templates select=".//tei:editor"/></td></tr>
                <tr><th>Funder(s)</th><td><xsl:value-of select=".//tei:funder"/></td></tr>
                <tr><th>Publisher</th><td><xsl:value-of select=".//tei:publicationStmt/tei:publisher"/></td></tr>
                <tr><th>Location</th><td><xsl:value-of select=".//tei:pubPlace"/></td></tr>
                <tr><th>Source</th><td><xsl:value-of select=".//tei:sourceDesc/tei:p"/></td></tr>
                <tr><th>License</th><td><xsl:value-of select=".//tei:availability/tei:p"/></td></tr>
                <tr><th>Subject</th><td><xsl:value-of select=".//tei:keywords/tei:term"/></td></tr>
            </table>
        </section>
    </xsl:template>
    
    <!-- Body -->
    <xsl:template match="tei:body">
        <section class="body">
            <xsl:apply-templates/>
        </section>
    </xsl:template>
    
    <xsl:template match="tei:ab">
        <article class="speech">
            <xsl:apply-templates/>
        </article>
    </xsl:template>
    
    <xsl:template match="tei:seg[@type='publ']">
        <p class="paragraph">
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    
    <!-- <xsl:template match="tei:s">
        <div class="sentence"><xsl:apply-templates/></div>
    </xsl:template> -->
    
    <!-- Line Breaks -->
    
    <xsl:template match="tei:lb">
        <br/>
    </xsl:template>
    
    <!-- Named Entities -->
    
    <!-- Person-->
    <xsl:template match="tei:persName">
        <xsl:choose>
            <!-- If persName has no text, skip rendering -->
            <xsl:when test="normalize-space(.) = ''"/>
            <xsl:otherwise>
                <span class="person" title="class:Person"><xsl:apply-templates/></span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Field -->
    <xsl:template match="tei:term">
        <span class="field" title="class:Field">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <!-- External References -->
    <xsl:template match="tei:bibl">
        <span class="source" title="class:WittgensteinExternalSource">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <!-- Point -->
    <!-- Point as <seg> inside <s> -->
    <xsl:template match="tei:s[tei:seg[@ana='onto:Point']]">
        <div class="sentence-with-point" title="class:Point(Claim)">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <xsl:template match="tei:seg[@ana='onto:Point']">
        <span class="point" title="class:Point(Claim)">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    
    <!-- Point as <s> -->
    <xsl:template match="tei:s[@ana='onto:Point']">
        <div class="point-sentence" title="class:Point(Claim)">
            <xsl:apply-templates/>
        </div>
    </xsl:template>



    
    
    <!-- Perspective -->
    <xsl:template match="tei:s[@ana='onto:Perspective'] | tei:seg[@ana='onto:Perspective']">
        <div class="perspective" title="class:Perspective">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <!-- Exemplification -->
    <xsl:template match="tei:s[@ana='onto:Exemplification'] | tei:seg[@ana='onto:Exemplification']">
        <div class="example" title="class:Exemplification">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <!-- Metaphor -->
    <xsl:template match="tei:seg[@ana='onto:Metaphor']">
        <span class="metaphor" title="class:Metaphor">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    
    
    
    <!-- Default: apply templates to everything else -->
    <xsl:template match="*">
        <xsl:apply-templates/>
    </xsl:template>
    
</xsl:stylesheet>
