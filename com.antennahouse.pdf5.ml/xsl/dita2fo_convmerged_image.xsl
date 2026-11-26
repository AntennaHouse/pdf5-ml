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
         - Convert image/@href that is written in preprocess2 to absolute URI.
         - Get image URI from .job.xml in temporary folder.
     -->

    <!--
     function:    image
     param:       none
     return:      self and descendant element
     note:        If preprocess2 is adopted, replace image/@href to absolute URI.
     -->
    <xsl:template match="*[contains-token(@class,'topic/image')][$pAdoptPreprocess2]" priority="10">
        <xsl:variable name="image" as="element()" select="."/>
        <xsl:variable name="href" as="xs:string" select="$image/@href => string()"/>
        <xsl:variable name="scope" as="xs:string" select="$image/@scope => string()"/>
        <xsl:copy>
            <xsl:copy-of select="@* except @href"/>
            <xsl:choose>
                <xsl:when test="ahf:isAbsoluteImage($image)">
                    <xsl:copy-of select="@href"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="imageUri" as="xs:string?" select="map:get($imageHrefToFileUriMap, $href)"/>
                    <xsl:choose>
                        <xsl:when test="$imageUri => exists()">
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
        <xsl:variable name="scope" as="xs:string" select="$prmImage/@scope => string()"/>
        <xsl:variable name="href" as="xs:string" select="$prmImage/@href => string()"/>
        <xsl:sequence select="$scope eq 'external' or ahf:isAbsoluteUri($href)"/>
    </xsl:function>
    
</xsl:stylesheet>
