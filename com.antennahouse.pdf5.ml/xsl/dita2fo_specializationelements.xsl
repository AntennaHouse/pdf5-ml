<?xml version='1.0' encoding="UTF-8" ?>
<!--
****************************************************************
DITA to XSL-FO Stylesheet 
Module: Specialization elements stylesheet
Copyright © 2009-2009 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL    : http://www.antennahouse.com/
E-mail : info@antennahouse.com
****************************************************************
-->
<xsl:stylesheet version="2.0" 
 xmlns:fo="http://www.w3.org/1999/XSL/Format" 
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
 exclude-result-prefixes="xs ahf"
>

    <!-- index-base is coded in dita2fo_indexcommon.xsl. (Only skip element.)-->
    <!-- required-cleanup is coded in dita2fo_regacyconversionelements.xsl -->
    
    <!-- 
     function:	data-about template
     param:	    
     return:	Only apply-templates for child elements
     note:		
     -->
    <xsl:template match="*[contains(@class,' topic/data-about ')]">
        <xsl:apply-templates/>
    </xsl:template>

    <!-- 
     function:	data
     param:	    
     return:	none
     note:		ignore descendant-or-self
                Call "processData" for overriding from other plug-ins.
                2015-08-25 t.makita
     -->
    <xsl:template match="*[contains(@class,' topic/data ')]">
        <xsl:call-template name="processData"/>
    </xsl:template>
    
    <xsl:template name="processData">
    </xsl:template>
    
    <!-- 
     function:	foreign template
     param:	    
     return:	If content is MathML or SVG return fo:wrapper & fo:instream-foreign-object
     note:		Added 2011-08-22 t.makita
     -->
    <xsl:template match="*[contains(@class, ' topic/foreign ')]">
        <xsl:variable name="childElem" select="child::*[1]" as="element()*"/>
    	<xsl:if test="exists($childElem)">
    		<fo:wrapper>
    	        <xsl:call-template name="ahf:getUnivAtts"/>
    		    <xsl:choose>
    			    <xsl:when test="namespace-uri($childElem)='http://www.w3.org/1998/Math/MathML'">
    			    	<!-- Content is MathML -->
    			        <fo:instream-foreign-object content-type="content-type:application/mathml+xml">
    			            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
    			            <xsl:copy-of select="$childElem"/>
    			        </fo:instream-foreign-object>
    			    </xsl:when>
    			    <xsl:when test="namespace-uri($childElem)='http://www.w3.org/2000/svg'">
    			    	<!-- Content is SVG -->
    			        <fo:instream-foreign-object content-type="content-type:image/svg+xml">
    			            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
    			            <xsl:copy-of select="$childElem"/>
    			        </fo:instream-foreign-object>
    			    </xsl:when>
    			</xsl:choose>
    		</fo:wrapper>
    	</xsl:if>
    </xsl:template>
    
    <!-- 
     function:	itemgroup template
     param:	    
     return:	fo:block
     note:		none
     -->
    <xsl:template match="*[contains(@class, ' topic/itemgroup ')]" mode="MODE_GET_STYLE" as="xs:string*">
        <xsl:sequence select="'atsItemGroup'"/>
    </xsl:template>    
    
    <xsl:template match="*[contains(@class,' topic/itemgroup ')]">
        <fo:block>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
    
    <!-- 
     function:	no-topic-nesting template
     param:	    
     return:	none
     note:		none
     -->
    <xsl:template match="*[contains(@class,' topic/no-topic-nesting ')]">
    </xsl:template>
    
    <!-- 
     function:	state template
     param:	    
     return:	fo:inline
     note:		return @name=@value inline.
     -->
    <xsl:template match="*[contains(@class, ' topic/state ')]" mode="MODE_GET_STYLE" as="xs:string*">
        <xsl:sequence select="'atsState'"/>
    </xsl:template>    
    
    <xsl:template match="*[contains(@class,' topic/state ')]">
        <fo:inline>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:value-of select="@name"/>
            <xsl:text>=</xsl:text>
            <xsl:value-of select="@value"/>
        </fo:inline>
    </xsl:template>
    
    <!-- 
     function:	boolean template
     param:	    
     return:	fo:inline
     note:		
     -->
    <xsl:template match="*[contains(@class, ' topic/boolean ')]" mode="MODE_GET_STYLE" as="xs:string*">
        <xsl:sequence select="'atsBoolean'"/>
    </xsl:template>    

    <xsl:template match="*[contains(@class,' topic/boolean ')]">
        <fo:inline>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:value-of select="@state"/>
        </fo:inline>
    </xsl:template>
    
    <!-- 
     function:	Unknown template
     param:	    
     return:	None
     note:		
     -->
    <xsl:template match="*[contains(@class,' topic/unknown ')]">
    </xsl:template>

</xsl:stylesheet>