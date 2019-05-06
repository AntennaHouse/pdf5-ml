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
         
         Make it possible to implement float figure in OASIS DTD & Schemas using@outputclass.

         <step>
           <cmd>Command of this step.</cmd>
           <info>
             <fig outputclass="flow-left/floa-right">
               <desc>Description of figure</desc>
               <image placement="break" href="..."/>
             </float>
           </info>
         </step>

         <p>
           <fig outputclass="flost-right">
             <image placement="break" href="tys125f.jpg"/>
           </fig>
           Scorpa is a manufacturer of trials motorcycles based near Alès, France. 
           It was founded in 1993 by Marc Teissier and Joël Domergue. 
           The first model produced by the company was the WORKS 294 in 1994, powered by a single-cylinder, two-stroke Rotax engine. 
           In 1998, Scorpa signed an agreement with Yamaha Motor Company to use its engines in subsequent models.
         </p>
         
         2019-05-06 t.makita
     -->
    <!-- 
     function:  Judge float figure
     param:     prmELem
     return:    xs:boolean
     note:      
     -->
    <xsl:variable name="ocFloatFigure" as="xs:string+" select="ahf:getVarValueAsStringSequence('ocFloatFigure')"/>
    <xsl:variable name="ocFloatFigGroup" as="xs:string+" select="ahf:getVarValueAsStringSequence('ocFloatFigGroup')"/>
    
    <xsl:function name="ahf:isFloatFigure" as="xs:boolean">
        <xsl:param name="prmElement" as="element()"/>
        <xsl:sequence select="exists($prmElement[contains(@class, ' floatfig-d/floatfig ')]) or exists($prmElement[contains(@class, ' topic/fig ')][ahf:getOutputClass($prmElement) = $ocFloatFigure])"/>
    </xsl:function>

    <xsl:variable name="floatSpecNone" as="xs:string" select="ahf:getVarValue('ocFloatNone')"/>
    <xsl:variable name="floatSpecLeft" as="xs:string" select="ahf:getVarValue('ocFloatLeft')"/>
    <xsl:variable name="floatSpecRight" as="xs:string" select="ahf:getVarValue('ocFloatRight')"/>

    <xsl:variable name="floatSpecAuto" as="xs:string" select="ahf:getVarValue('ocFloatAuto')"/>
    

    <!-- 
     function:  Judge float figure group
     param:     prmELem
     return:    xs:boolean
     note:      
     -->
    <xsl:function name="ahf:isFloatFigureGroup" as="xs:boolean">
        <xsl:param name="prmElement" as="element()"/>
        <xsl:sequence select="exists($prmElement[contains(@class, ' floatfig-d/floatfig-group ')]) or exists($prmElement[contains(@class, ' topic/figgroup ')][ahf:getOutputClass($prmElement) = $ocFloatFigure])"/>
    </xsl:function>

    <!-- 
     function:  Get float attribute
     param:     prmELem
     return:    float specification (none, left, right)
     note:      
     -->
    <xsl:function name="ahf:getFloatSpec" as="xs:string?">
        <xsl:param name="prmElement" as="element()"/>
        <xsl:choose>
            <xsl:when test="$prmElement[contains(@class, ' floatfig-d/floatfig ')]">
                <xsl:sequence select="$prmElement/@float"/>
            </xsl:when>
            <xsl:when test="$prmElement[contains(@class, ' topic/fig ')][ahf:getOutputClass($prmElement) = $ocFloatFigure]">
                <xsl:variable name="outputClass" as="xs:string+" select="ahf:getOutputClass($prmElement)"/>
                <xsl:choose>
                    <xsl:when test="$outputClass = $floatSpecNone">
                        <xsl:sequence select="'none'"/>
                    </xsl:when>
                    <xsl:when test="$outputClass = $floatSpecLeft">
                        <xsl:sequence select="'left'"/>
                    </xsl:when>
                    <xsl:when test="$outputClass = $floatSpecRight">
                        <xsl:sequence select="'right'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- 
     function:  Get float attribute for flost-figgroup
     param:     prmELem
     return:    float specification (none, left, right)
     note:      
     -->
    <xsl:function name="ahf:getFloatFigGroupSpec" as="xs:string?">
        <xsl:param name="prmElement" as="element()"/>
        <xsl:choose>
            <xsl:when test="$prmElement[contains(@class, ' floatfig-d/floatfig ')]">
                <xsl:sequence select="$prmElement/@float"/>
            </xsl:when>
            <xsl:when test="$prmElement[contains(@class, ' topic/figgroup ')][ahf:getOutputClass($prmElement) = $ocFloatFigGroup]">
                <xsl:variable name="outputClass" as="xs:string+" select="ahf:getOutputClass($prmElement)"/>
                <xsl:choose>
                    <xsl:when test="$outputClass = $floatSpecAuto">
                        <xsl:sequence select="'auto'"/>
                    </xsl:when>
                    <xsl:when test="$outputClass = $floatSpecLeft">
                        <xsl:sequence select="'left'"/>
                    </xsl:when>
                    <xsl:when test="$outputClass = $floatSpecRight">
                        <xsl:sequence select="'right'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    

    <!-- 
     function:  floating figure
     param:     
     return:    fo:float or fo:wrapper
     note:      This function is still experimental.
     -->
    <xsl:template match="*[ahf:isFloatFigure(.)]" mode="MODE_GET_STYLE" as="xs:string*" priority="2">
        <xsl:variable name="float" as="xs:string?" select="ahf:getFloatSpec(.)"/>
        <xsl:choose>
            <xsl:when test="$float eq 'left'">
                <xsl:sequence select="'atsFloatFigLeft'"/>
                <xsl:if test="preceding-sibling::*[ahf:isFloatFigure(.)][ahf:getFloatSpec(.) eq 'left']">
                    <xsl:sequence select="'atsFloatMoveAutoNext'"/>
                </xsl:if>
            </xsl:when>
            <xsl:when test="$float eq 'right'">
                <xsl:sequence select="'atsFloatFigRight'"/>
                <xsl:if test="preceding-sibling::*[ahf:isFloatFigure(.)][ahf:getFloatSpec(.) eq 'right']">
                    <xsl:sequence select="'atsFloatMoveAutoNext'"/>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*[ahf:isFloatFigure(.)][ahf:getFloatSpec(.) = ($floatSpecLeft,$floatSpecRight)]" priority="2" name="processFloatFigLR">
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

    <xsl:template match="*[ahf:isFloatFigure(.)][ahf:getFloatSpec(.) = $floatSpecNone]" priority="2" name="processFloatFigNone">
        <fo:wrapper>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates select="node() except *[contains(@class, ' topic/title ')]"/>
            <xsl:apply-templates select="*[contains(@class, ' topic/title ')]"/>
        </fo:wrapper>
    </xsl:template>

    <!-- 
     function:  floating figure group
     param:     
     return:    fo:float
     note:      This function is experimental.
     -->
    <xsl:template match="*[ahf:isFloatFigureGroup(.)]" mode="MODE_GET_STYLE" as="xs:string*" priority="2">
        <xsl:variable name="float" as="xs:string?" select="ahf:getFloatFigGroupSpec(.)"/>
        <xsl:choose>
            <xsl:when test="$float eq 'left'">
                <xsl:sequence select="'atsFloatFigGroupLeft'"/>
                <xsl:if test="preceding-sibling::*[ahf:isFloatFigureGroup(.)][ahf:getFloatFigGroupSpec(.) eq 'left']">
                    <xsl:sequence select="'atsFloatMoveAutoNext'"/>
                </xsl:if>
            </xsl:when>
            <xsl:when test="$float eq 'right'">
                <xsl:sequence select="'atsFloatFigGroupRight'"/>
                <xsl:if test="preceding-sibling::*[ahf:isFloatFigureGroup(.)][ahf:getFloatFigGroupSpec(.) eq 'right']">
                    <xsl:sequence select="'atsFloatMoveAutoNext'"/>
                </xsl:if>
            </xsl:when>
            <!-- @float='auto" inherits preceding-sibling floatfig-group/@float and @clear is set to 'none'-->
            <xsl:when test="$float eq 'auto'">
                <xsl:apply-templates select="(preceding-sibling::*[ahf:isFloatFigureGroup(.)][ahf:getFloatFigGroupSpec(.) ne 'auto'])[1]" mode="MODE_GET_STYLE"/>
                <xsl:sequence select="'atsFloatFigGroupAuto'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="*[ahf:isFloatFigureGroup(.)]" priority="2">
        <fo:float>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <fo:block-container>
                <xsl:call-template name="getAttributeSet">
                    <xsl:with-param name="prmAttrSetName" select="'atsFloatFigGroupBc'"/>
                </xsl:call-template>
                <fo:block>
                    <xsl:apply-templates select="node() except *[contains(@class, ' topic/title ')]"/>
                    <xsl:apply-templates select="*[contains(@class, ' topic/title ')]"/>
                </fo:block>
            </fo:block-container>
        </fo:float>
    </xsl:template>

</xsl:stylesheet>
