<?xml version='1.0' encoding="UTF-8" ?>
<!--
****************************************************************
DITA to XSL-FO Stylesheet
Module: Floating figure module
Copyright © 2009-2012 Antenna House, Inc. All rights reserved.
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
    <!-- This stylesheet expresses an floating image using floatfig/@float="left/right".
         @float is specialized attribute for floatfig element.
         Floating image is typically used in task's step by following authoring.
         
         <step>
           <cmd>Command of this step.</cmd>
           <info>
             <floatfig float="left/right">
               <desc>Description of figure</desc>
               <image placement="break" href="..."/>
             </floatfig>
           </info>
         </step>

         In this case floatfig is converted into fo:float as if it exists in <cmd>.
         (Not yet implemented.)

         Or it may be inserted in simple <p> element.

         <p>
           <floatfig float="right">
             <image placement="break" href="tys125f.jpg"/>
           </floatfig>
           Scorpa is a manufacturer of trials motorcycles based near Alès, France. 
           It was founded in 1993 by Marc Teissier and Joël Domergue. 
           The first model produced by the company was the WORKS 294 in 1994, powered by a single-cylinder, two-stroke Rotax engine. 
           In 1998, Scorpa signed an agreement with Yamaha Motor Company to use its engines in subsequent models.
         </p>
         
         floatfig is available in ah-dita specialization.
         https://github.com/AntennaHouse/ah-dita/tree/master/com.antennahouse.dita.dita13.doctypes
     -->
    <!-- 
     function:  floating figure
     param:     
     return:    fo:float or fo:wrapper
     note:      This function is still experimental.
     -->
    <xsl:template match="*[contains(@class, ' floatfig-d/floatfig ')]" mode="MODE_GET_STYLE" as="xs:string*" priority="2">
        <xsl:variable name="float" as="xs:string" select="string(@float)"/>
        <xsl:choose>
            <xsl:when test="$float eq 'left'">
                <xsl:sequence select="'atsFloatFigLeft'"/>
                <xsl:if test="preceding-sibling::*[contains(@class, ' floatfig-d/floatfig ')][string(@float) eq 'left']">
                    <xsl:sequence select="'atsFloatMoveAutoNext'"/>
                </xsl:if>
            </xsl:when>
            <xsl:when test="$float eq 'right'">
                <xsl:sequence select="'atsFloatFigRight'"/>
                <xsl:if test="preceding-sibling::*[contains(@class, ' floatfig-d/floatfig ')][string(@float) eq 'right']">
                    <xsl:sequence select="'atsFloatMoveAutoNext'"/>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' floatfig-d/floatfig ')][string(@float) = ('left','right')]" priority="2" name="processFloatFigLR">
        <fo:float>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <fo:block-container>
                <xsl:call-template name="getAttributeSet">
                    <xsl:with-param name="prmAttrSetName" select="'atsFloatFigBc'"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </fo:block-container>
        </fo:float>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' floatfig-d/floatfig ')][string(@float) eq 'none']" priority="2" name="processFloatFigNone">
        <fo:wrapper>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates/>
        </fo:wrapper>
    </xsl:template>

    <!-- 
     function:  floating figure group
     param:     
     return:    fo:float
     note:      This function is experimental.
     -->
    <xsl:template match="*[contains(@class, ' floatfig-d/floatfig-group ')]" mode="MODE_GET_STYLE" as="xs:string*" priority="2">
        <xsl:variable name="float" as="xs:string" select="string(@float)"/>
        <xsl:choose>
            <xsl:when test="$float eq 'left'">
                <xsl:sequence select="'atsFloatFigGroupLeft'"/>
                <xsl:if test="preceding-sibling::*[contains(@class, ' floatfig-d/floatfig-group ')][string(@float) eq 'left']">
                    <xsl:sequence select="'atsFloatMoveAutoNext'"/>
                </xsl:if>
            </xsl:when>
            <xsl:when test="$float eq 'right'">
                <xsl:sequence select="'atsFloatFigGroupRight'"/>
                <xsl:if test="preceding-sibling::*[contains(@class, ' floatfig-d/floatfig-group ')][string(@float) eq 'right']">
                    <xsl:sequence select="'atsFloatMoveAutoNext'"/>
                </xsl:if>
            </xsl:when>
            <!-- @float='auto" inherits preceding-sibling floatfig-group/@float and @clear is set to 'none'-->
            <xsl:when test="$float eq 'auto'">
                <xsl:apply-templates select="(preceding-sibling::*[contains(@class, ' floatfig-d/floatfig-group ')][string(@float) ne 'none'])[1]" mode="MODE_GET_STYLE"/>
                <xsl:sequence select="'atsFloatFigGroupAuto'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' floatfig-d/floatfig-group ')]" priority="2">
        <fo:float>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <fo:block-container>
                <xsl:call-template name="getAttributeSet">
                    <xsl:with-param name="prmAttrSetName" select="'atsFloatFigGroupBc'"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </fo:block-container>
        </fo:float>
    </xsl:template>

</xsl:stylesheet>
