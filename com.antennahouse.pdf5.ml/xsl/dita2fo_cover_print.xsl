<?xml version="1.0" encoding="UTF-8"?>
<!--
****************************************************************
DITA to XSL-FO Stylesheet 
Module: Cover stylesheet
Copyright © 2009-2015 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL    : http://www.antennahouse.com/
E-mail : info@antennahouse.com
****************************************************************
-->
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions"
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    xmlns:ahp="http://www.antennahouse.com/names/XSLT/Document/PageControl"
    xmlns:psmi="http://www.CraneSoftwrights.com/resources/psmi"
    xmlns:saxon="http://saxon.sf.net/"
    exclude-result-prefixes="xs ahf saxon">

    <!-- ahf:isCoverTopicRef is moved to dita2fo_dita_util.xsl -->

    <!-- 
     function:	Return topicref is for cover3 
     param:		prmTopicRef
     return:	xs:boolean
     note:		
     -->
    <xsl:function name="ahf:isCover3TopicRef" as="xs:boolean">
        <xsl:param name="prmTopicRef" as="element()"/>
        <xsl:variable name="outputClass" as="xs:string" select="string($prmTopicRef/@outputclass)"/>
        <xsl:sequence select="matches($outputClass,'cover3')"/>
    </xsl:function>
    

    <!-- 
     function:	Output cover N 
     param:		prmTopicContent
     return:	psmi:page-sequence
     note:		
     -->
    <xsl:template name="outputCoverN">
        <xsl:param name="prmTopicContent" as="element()" required="yes"/>
        <xsl:param name="prmTopicRef" tunnel="yes" as="element()" required="yes"/>
        <psmi:page-sequence>
            <xsl:copy-of select="ahf:getAttributeSet('atsPageSeqCoverForPrint')"/>
            <xsl:if test="$pIncludeCoverIntoPageCounting">
                <!-- Mark psmi:page-sequence as not cover -->
                <xsl:attribute name="ahp:cover" select="'false'"/>
            </xsl:if>
            <xsl:if test="$pIsPrintOutput and ahf:isCover3TopicRef($prmTopicRef)">
                <!-- Start cover3 from odd page -->
                <xsl:attribute name="initial-page-number" select="'auto-odd'"/>
            </xsl:if>
            <fo:flow flow-name="xsl-region-body">
                <fo:block-container>
                    <xsl:call-template name="ahf:getIdAtts">
                        <xsl:with-param name="prmElement" select="$prmTopicContent"/>
                    </xsl:call-template>
                    <xsl:copy-of select="ahf:getAttributeSetWithPageVariables('atsCoverBlockContainer')"/>
                    <xsl:apply-templates select="$prmTopicContent/*[contains(@class,'topic/body ')]"/>
                </fo:block-container>
            </fo:flow>
        </psmi:page-sequence>
    </xsl:template>
    
    <!-- 
     function:	body for cover
     param:	    prmTopicRef
     return:	fo:wrapper
     note:		
     -->
    <xsl:template match="*[contains(@class, ' topic/body ')]" priority="20">
        <xsl:param name="prmTopicRef" tunnel="yes" required="yes" as="element()?"/>
        <xsl:choose>
            <xsl:when test="ahf:isCoverTopicRef($prmTopicRef)">
                <fo:wrapper>
                    <xsl:copy-of select="ahf:getFoProperty(.)"/>
                    <xsl:apply-templates/>
                </fo:wrapper>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- 
     function:	bodydiv for cover
     param:		prmTopicRef
     return:	fo:block-container
     note:		
     -->
    <xsl:template match="*[contains(@class, ' topic/bodydiv ')]" priority="20">
        <xsl:param name="prmTopicRef" tunnel="yes" required="yes" as="element()?"/>
        <xsl:choose>
            <xsl:when test="ahf:isCoverTopicRef($prmTopicRef)">
                <fo:block-container>
                    <xsl:copy-of select="ahf:getFoPropertyWithPageVariables(.)"/>
                    <xsl:apply-templates/>
                </fo:block-container>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>    

    <!-- 
     function:	bodydiv for cover backgroound
     param:		prmTopicRef
     return:	fo:block-container
     note:		
     -->
    <xsl:template match="*[contains(@class, ' topic/bodydiv ')][descendant::*[contains(@class,' topic/image ')][@outputclass eq 'background']]" priority="22">
        <xsl:param name="prmTopicRef" tunnel="yes" required="yes" as="element()?"/>
        <xsl:choose>
            <xsl:when test="ahf:isCoverTopicRef($prmTopicRef)">
                <xsl:variable name="bgImageElem" as="element()*" select="descendant::*[contains(@class,' topic/image ')][@outputclass eq 'background'][1]"/>
                <xsl:variable name="bgImageHref" as="xs:string" select="concat('url(',$pMapDirUrl,string($bgImageElem/@href),')')"/>
                <fo:block-container>
                    <xsl:variable name="foProperty" as="attribute()*" select="ahf:getFoPropertyWithPageVariables(.)"/>
                    <xsl:copy-of select="$foProperty"/>
                    <xsl:copy-of select="ahf:getFoPropertyWithPageVariables($bgImageElem)[name() ne 'href']"/>
                    <xsl:attribute name="background-image" select="$bgImageHref"/>
                </fo:block-container>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- 
     function:	section for cover
     param:		prmTopicRef
     return:	fo:block
     note:		
     -->
    <xsl:template match="*[contains(@class, ' topic/section ')]" priority="20">
        <xsl:param name="prmTopicRef" tunnel="yes" required="yes" as="element()?"/>
        <xsl:choose>
            <xsl:when test="ahf:isCoverTopicRef($prmTopicRef)">
                <fo:block>
                    <xsl:copy-of select="ahf:getFoPropertyWithPageVariables(.)"/>
                    <xsl:apply-templates/>
                </fo:block>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- 
     function:	draft-comment for cover
     param:		prmTopicRef
     return:	ignore
     note:		
     -->
    <xsl:template match="*[contains(@class, ' topic/draft-comment ')]" priority="20" mode="TEXT_ONLY">
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' topic/draft-comment ')]" priority="20">
        <xsl:param name="prmTopicRef" tunnel="yes" required="yes" as="element()?"/>
        <xsl:choose>
            <xsl:when test="ahf:isCoverTopicRef($prmTopicRef)"/>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- 
     function:	image for cover
     param:		prmTopicRef
     return:	see probe
     note:		
     -->
    <xsl:template match="*[contains(@class, ' topic/image ')]" priority="20">
        <xsl:param name="prmTopicRef" tunnel="yes" required="yes" as="element()?"/>
        <xsl:choose>
            <xsl:when test="not(ahf:isCoverTopicRef($prmTopicRef))">
                <xsl:next-match/>
            </xsl:when>
            <xsl:when test="string(@placement) eq 'break'">
                <!-- block level image -->
                <xsl:choose>
                    <xsl:when test="$pAutoScaleDownToFit">
                        <fo:block-container>
                            <fo:block start-indent="0mm">
                                <xsl:copy-of select="ahf:getImageBlockAttr(.)"/>
                                <!-- Image processing -->
                                <xsl:call-template name="ahf:processImage"/>
                                <xsl:apply-templates/>
                            </fo:block>
                        </fo:block-container>                    
                    </xsl:when>
                    <xsl:otherwise>
                        <fo:block>
                            <xsl:copy-of select="ahf:getImageBlockAttr(.)"/>
                            <!-- Image processing -->
                            <xsl:call-template name="ahf:processImage"/>
                            <xsl:apply-templates/>
                        </fo:block>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <!-- inline level image -->
                <fo:inline>
                    <xsl:call-template name="ahf:processImage">
                        <xsl:with-param name="prmImage" select="."/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </fo:inline>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- 
     function:	data for cover: generates barcode
     param:		prmTopicRef
     return:	fo:external-graphic
     note:      assume data/@name="barcode" express barcode
     -->
    <xsl:template match="*[contains(@class, ' topic/data ')][string(@name) eq 'barcode']" priority="20">
        <xsl:param name="prmTopicRef" tunnel="yes" required="yes" as="element()?"/>
        <xsl:choose>
            <xsl:when test="ahf:isCoverTopicRef($prmTopicRef)">
                <xsl:variable name="text" as="xs:string">
                    <xsl:variable name="texts" as="xs:string*">
                        <xsl:apply-templates select="child::node()" mode="TEXT_ONLY"/>
                    </xsl:variable>
                    <xsl:sequence select="normalize-space(string-join($texts,''))"/>
                </xsl:variable>
                <xsl:variable name="barCodeSrc" as="xs:string" select="concat(ahf:getVarValue('cBarCodeSrc'),$text)"/>
                <fo:external-graphic>
                    <xsl:attribute name="src" select="$barCodeSrc"/>
                    <xsl:copy-of select="ahf:getFoPropertyWithPageVariables(.)"/>
                </fo:external-graphic>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- 
     function:	data for cover: QR code
     param:		prmTopicRef
     return:	fo:external-graphic
     note:      data/@name="qrcode" expresses QR code
                data/@href is the target URL
     -->
    <xsl:template match="*[contains(@class, ' topic/data ')][string(@name) eq 'qrcode']" priority="20">
        <xsl:param name="prmTopicRef" tunnel="yes" required="yes" as="element()?"/>
        <xsl:choose>
            <xsl:when test="ahf:isCoverTopicRef($prmTopicRef)">
                    <xsl:variable name="href" as="xs:string" select="string(@href)"/>
                    <xsl:variable name="qrCodeSrc" as="xs:string" select="concat(ahf:getVarValue('cQrCodeSrc'),$href)"/>
                    <fo:external-graphic>
                        <xsl:attribute name="src" select="$qrCodeSrc"/>
                        <xsl:copy-of select="ahf:getFoPropertyWithPageVariables(.)"/>
                    </fo:external-graphic>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- 
     function:	p for cover
     param:		prmTopicRef
     return:	fo:block
     note:      		
     -->
    <xsl:template match="*[contains(@class, ' topic/p ')]" priority="20">
        <xsl:param name="prmTopicRef" tunnel="yes" required="yes" as="element()?"/>
        <xsl:choose>
            <xsl:when test="ahf:isCoverTopicRef($prmTopicRef)">
                <fo:block>
                    <xsl:copy-of select="ahf:getFoPropertyWithPageVariables(.)"/>
                    <xsl:apply-templates/>
                </fo:block>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- 
        function:	ph for cover
        param:	    prmTopicRef
        return:	    fo:inline-container, fo:block
        note:		
    -->
    <xsl:template match="*[contains(@class,' topic/ph ')][string(@outputclass) eq 'inline-container']" priority="20">
        <xsl:param name="prmTopicRef" tunnel="yes" required="yes" as="element()?"/>
        
        <xsl:choose>
            <xsl:when test="ahf:isCoverTopicRef($prmTopicRef)">
                <fo:inline-container>
                    <xsl:copy-of select="ahf:getFoPropertyWithPageVariables(.)"/>
                    <xsl:apply-templates/>
                </fo:inline-container>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' topic/ph ')][string(@outputclass) eq 'block']" priority="20">
        <xsl:param name="prmTopicRef" tunnel="yes" required="yes" as="element()?"/>
        
        <xsl:choose>
            <xsl:when test="ahf:isCoverTopicRef($prmTopicRef)">
                <fo:block>
                    <xsl:copy-of select="ahf:getFoPropertyWithPageVariables(.)"/>
                    <xsl:apply-templates/>
                </fo:block>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
</xsl:stylesheet>