<?xml version='1.0' encoding="UTF-8" ?>
<!--
****************************************************************
DITA to XSL-FO Stylesheet
Module: Generate cover
Copyright © 2009-2009 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL    : http://www.antennahouse.com/
E-mail : info@antennahouse.com
****************************************************************
-->
<xsl:stylesheet version="2.0" 
 xmlns:fo="http://www.w3.org/1999/XSL/Format" 
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions"
 xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
 exclude-result-prefixes="ahf" 
>

    <!-- 
     function:	cover generate template
     param:		none
     return:	fo:page-sequence
     note:		Current context is "/". 
     -->
    <xsl:template name="genCover">
        <fo:page-sequence master-reference="pmsPageSeqCover">
            <xsl:copy-of select="ahf:getAttributeSet('atsPageSeqBase')"/>
            <fo:flow flow-name="xsl-region-body">
                <fo:block-container>
                    <xsl:copy-of select="ahf:getAttributeSet('atsCoverBookTitleBC')"/>
                    <xsl:if test="exists($bookLibrary)">
                        <fo:block>
                            <xsl:copy-of select="ahf:getAttributeSet('atsCoverBookLibrary')"/>
                            <xsl:copy-of select="$bookLibrary"/>
                        </fo:block>
                    </xsl:if>
                    <fo:block>
                        <xsl:copy-of select="ahf:getAttributeSet('atsCoverBookTitle')"/>
                        <xsl:copy-of select="$bookTitle"/>
                    </fo:block>
                    <xsl:if test="exists($bookAltTitle)">
                        <fo:block>
                            <xsl:copy-of select="ahf:getAttributeSet('atsCoverAltBookTitle')"/>
                            <xsl:copy-of select="$bookAltTitle"/>
                        </fo:block>
                    </xsl:if>
                </fo:block-container>
                <fo:block-container>
                    <xsl:copy-of select="ahf:getAttributeSet('atsCoverBookMetaBC')"/>
                    <fo:block>
                        <xsl:copy-of select="ahf:getAttributeSet('atsCoverBookMeta')"/>
                        <xsl:apply-templates select="$map//*[contains(@class,' bookmap/bookmeta ')]" mode="cover"/>
                    </fo:block>
                </fo:block-container>
            </fo:flow>
        </fo:page-sequence>
    </xsl:template>
    
    <!-- 
     function:	Bookmeta output template
     param:		none
     return:	fo:block
     note:		none
     -->
    <xsl:template match="*[contains(@class, ' bookmap/bookmeta ')]" mode="cover">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' xnal-d/namedetails ')]" mode="cover">
        <fo:block>
            <xsl:apply-templates mode="#current"/>
        </fo:block>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' xnal-d/addressdetails ')]" mode="cover">
        <fo:block>
            <xsl:apply-templates mode="#current"/>
        </fo:block>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' xnal-d/contactnumbers ')]" mode="cover">
        <fo:block>
            <xsl:apply-templates mode="#current"/>
        </fo:block>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' xnal-d/emailaddresses ')]" mode="cover">
        <fo:block>
            <xsl:apply-templates mode="#current"/>
        </fo:block>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' topic/source ')]" mode="cover"/>
    
    <xsl:template match="*[contains(@class, ' bookmap/publisherinformation ')]" mode="cover">
        <fo:block>
            <xsl:apply-templates mode="#current"/>
        </fo:block>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' bookmap/bookmeta ')]//*[contains(@class, ' topic/category ')]" mode="cover"/>
    
    <xsl:template match="*[contains(@class, ' bookmap/bookmeta ')]//*[contains(@class, ' topic/keywords ')]" mode="cover"/>
    
    <xsl:template match="*[contains(@class, ' bookmap/bookmeta ')]//*[contains(@class, ' topic/prodinfo ')]" mode="cover"/>
    
    <xsl:template match="*[contains(@class, ' bookmap/bookid ')]" mode="cover">
        <fo:block>
            <xsl:apply-templates mode="#current"/>
        </fo:block>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' bookmap/bookrights ')]" mode="cover">
        <fo:block>
            <xsl:apply-templates mode="#current"/>
        </fo:block>
    </xsl:template>
    
    <xsl:template match="*" mode="cover">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>

</xsl:stylesheet>
