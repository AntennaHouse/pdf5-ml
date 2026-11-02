<?xml version='1.0' encoding="UTF-8" ?>
<!--
    ****************************************************************
    DITA to XML Stylesheet
    Module: Merged file image map
    Copyright © 2009-2026 Antenna House, Inc. All rights reserved.
    Antenna House is a trademark of Antenna House, Inc.
    URL    : http://www.antennahouse.com/
    E-mail : info@antennahouse.com
    ****************************************************************
-->
<xsl:stylesheet version="3.0" 
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:map="http://www.w3.org/2005/xpath-functions/map"
 xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
 xmlns:uriutil="java:com.antennahouse.xslt.extension.RelUriUtil"
 exclude-result-prefixes="xs map ahf uriutil"
>
    <!-- .job.xml
         @uri to @src map
         Get image absolute URI from .job.xml in temporary folder.
     -->

    <xsl:variable name="imageHrefToFileUriMap" as="map(*)">
        <xsl:map>
            <xsl:for-each select="$pJobXmlDoc/job/files/file[@format eq 'image']">
                <xsl:variable name="file" as="element()" select="."/>
                <!-- example: clean-preprocess.use-result-filename=false 
                    @uri="5dec42c2e803286d448f9ab87e61db729849b04a.tif"
                    @src="file:/C:/Users/Toshihiko%20Makita/OneDrive/Document/User/ACME/sample-data/images/bird.tif"
                    
                     example: clean-preprocess.use-result-filename=true
                    @uri="common-image/tys125f.jpg"
                    @src="file:/X:/User/ah-xhtml5/dita-oxygen/flagging/common-image/tys125f.jpg"
                 -->
                <xsl:map-entry key="$file/@uri => string()" select="$file/@src => string()"/>
            </xsl:for-each>
        </xsl:map>
    </xsl:variable>
    
</xsl:stylesheet>
