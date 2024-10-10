<?xml version='1.0' encoding="UTF-8" ?>
<!--
    ****************************************************************
    DITA to XML Stylesheet
    Module: Merged file conversion templates
    Copyright © 2009-2023 Antenna House, Inc. All rights reserved.
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
    <!-- dita2fo_convmerged_image.xsl
         - Convert image/@href that is written in preprocess2 to relative path from main map.
         - Get main map and image URL from .job.xml in temporary folder.
     -->

    <xsl:variable name="imageHrefToFileUriMap" as="map(*)">
        <xsl:map>
            <xsl:for-each select="$pJobXmlDoc/job/files/file[@format eq 'image']">
                <xsl:variable name="file" as="element()" select="."/>
                <!-- 例： @uri="5dec42c2e803286d448f9ab87e61db729849b04a.tif"
                          @src="file:/C:/Users/Toshihiko%20Makita/OneDrive/Document/User/ACME/sample-data/images/bird.tif" 
                 -->
                <xsl:map-entry key="$file/@uri => string()" select="$file/@src => string()"/>
            </xsl:for-each>
        </xsl:map>
    </xsl:variable>
    
    <!--xsl:variable name="inputMapUri" as="xs:string">
        <xsl:variable name="string" as="element()?" select="$pJobXmlDoc/job/property[@name eq 'InputMapDir.uri']/string"/>
        <xsl:choose>
            <xsl:when test="exists($string)">
                <xsl:sequence select="$string => string()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="errorExit">
                    <xsl:with-param name="prmMes" select="ahf:replace($stMes5030,('%url'),($pJobXmlUrl))"/>
                </xsl:call-template>
                <xsl:sequence select="''"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable-->
    
    <!--
     function:    image
     param:       none
     return:      self and descendant element
     note:        If preprocess2 is adopted, replace image/@href to relative path to main map.
     -->
    <xsl:template match="*[contains-token(@class,'topic/image')][$pAdoptPreprocess2]" priority="10">
        <xsl:variable name="image" as="element()" select="."/>
        <xsl:variable name="href" as="xs:string" select="$image/@href => string()"/>
        <xsl:variable name="scope" as="xs:string" select="$image/@scope => string()"/>
        <xsl:copy>
            <xsl:copy-of select="@* except @href"/>
            <xsl:choose>
                <xsl:when test="$scope eq 'external' or ahf:isAbsoluteImage($image)">
                    <xsl:copy-of select="@href"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="imageUri" as="xs:string?" select="map:get($imageHrefToFileUriMap, $href)"/>
                    <xsl:choose>
                        <xsl:when test="$imageUri => exists()">
                            <!--xsl:variable name="relativePath" as="xs:string" select="uriutil:getRelativePath($imageUri, $inputMapUri)"/-->
                            <xsl:attribute name="href" select="$imageUri"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="errorExit">
                                <xsl:with-param name="prmMes" select="ahf:replace($stMes5032,('%image-url','%url'),($imageUri, $pJobXmlUrl))"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <!--
     function:    return image/@href is absolute
     param:       prmImage
     return:      xs:boolean
     note:        
     -->
    <xsl:function name="ahf:isAbsoluteImage" as="xs:boolean">
        <xsl:param name="prmImage" as="element()"/>
        <xsl:variable name="href" as="xs:string" select="$prmImage/@href => string()"/>
        <xsl:sequence select="some $prefix in ('/', 'file:') satisfies starts-with($href, $prefix) or contains($href, '://')"/>
    </xsl:function>

</xsl:stylesheet>
