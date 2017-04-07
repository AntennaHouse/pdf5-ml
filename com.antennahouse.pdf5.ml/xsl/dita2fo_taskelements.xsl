<?xml version='1.0' encoding="UTF-8" ?>
<!--
****************************************************************
DITA to XSL-FO Stylesheet 
Module: Task elements stylesheet
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
 exclude-result-prefixes="ahf"
>
    <!-- NOTE: task/title is coded in dita2fo_title.xsl -->
    <!-- NOTE: task/titlealts is implemented in dita2fo_topic.xsl as topic/titlealts -->
    <!-- NOTE: task/shortdesc is implemented in dita2fo_topic.xsl as topic/shortdesc -->
    <!-- NOTE: task/abstract is implemented in dita2fo_topic.xsl as topic/abstract -->
    <!-- NOTE: task/prolog is implemented in dita2fo_topic.xsl as topic/prolog -->
    <!-- NOTE: task/taskbody is implemented in dita2fo_topic.xsl as topic/body -->
    <!-- NOTE: task/prereq is implemented in dita2fo_topic.xsl as topic/section -->
    <!-- NOTE: task/context is implemented in dita2fo_topic.xsl as topic/section -->
    <!-- NOTE: task/steps-informal is implemented in dita2fo_bodyelemets.xsl as topic/section -->
    <!-- NOTE: task/steps-unordered is implemented in dita2fo_bodyelemets.xsl as topic/ul -->
    <!-- NOTE: task/choices is implemented in dita2fo_bodyelemets.xsl as topic/ul -->
    <!-- NOTE: task/choice is implemented in dita2fo_bodyelemets.xsl as topic/li -->
    
    <!-- 
     function:	steps template
     param:	    
     return:	fo:list-block
     note:      No fn elements supposed in the steps		
     -->
    <xsl:template match="*[contains(@class, ' task/steps ')]" mode="MODE_GET_STYLE" as="xs:string*" priority="2">
        <xsl:sequence select="'atsSteps'"/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' task/steps ')]" priority="2">
        <xsl:call-template name="processSteps"/>
    </xsl:template>
    
    <xsl:template name="processSteps">
        <!-- Prefix of step -->
        <xsl:variable name="stepNumberFormat" as="xs:string+">
            <xsl:call-template name="getVarValueWithLangAsStringSequence">
                <xsl:with-param name="prmVarName" select="'Step_Number_Formats'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="numberFormat" select="ahf:getOlNumberFormat(.,$stepNumberFormat)" as="xs:string"/>
        <fo:list-block>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates>
                <xsl:with-param name="prmNumberFormat" select="$numberFormat"/>
            </xsl:apply-templates>
        </fo:list-block>
    </xsl:template>
    
    <!-- 
     function:	steps/step template
     param:	    prmNumberFormat
     return:	fo:list-item
     note:		
     -->
    <xsl:template match="*[contains(@class, ' task/steps ')]/*[contains(@class,' task/step ')]" mode="MODE_GET_STYLE" as="xs:string*" priority="2">
        <xsl:sequence select="'atsStepItem'"/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' task/steps ')]/*[contains(@class,' task/step ')]" priority="2">
        <xsl:param name="prmNumberFormat" required="yes" as="xs:string"/>
        
        <xsl:call-template name="processStep">
            <xsl:with-param name="prmNumberFormat" select="$prmNumberFormat"/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template name="processStep">
        <xsl:param name="prmNumberFormat" required="yes" as="xs:string"/>
        
        <fo:list-item>
            <!-- Set list-item attribute. -->
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <fo:list-item-label end-indent="label-end()"> 
                <fo:block>
                    <xsl:call-template name="getAttributeSetWithLang">
                        <xsl:with-param name="prmAttrSetName" select="'atsStepLabel'"/>
                    </xsl:call-template>
                    <xsl:number format="{$prmNumberFormat}" value="count(preceding-sibling::*[contains(@class,' topic/li ')][not(contains(@class,' task/stepsection '))]) + 1"/>
                </fo:block>
            </fo:list-item-label>
            <fo:list-item-body start-indent="body-start()">
                <xsl:call-template name="getAttributeSetWithLang">
                    <xsl:with-param name="prmAttrSetName" select="'atsStepBody'"/>
                </xsl:call-template>
                <!-- Pull info/floatfig -->
                <xsl:for-each select="*[contains(@class,' task/info ')]//*[contains(@class,' floatfig-d/floatfig ')]">
                    <xsl:choose>
                        <xsl:when test="string(@float) = ('left','right')">
                            <xsl:call-template name="processFloatFigLR"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="processFloatFigNone"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
                <fo:block>
                    <xsl:call-template name="getAttributeSetWithLang">
                        <xsl:with-param name="prmAttrSetName" select="'atsP'"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </fo:block>
            </fo:list-item-body>
        </fo:list-item>
    </xsl:template>
    
    <!-- Ignore floatfig in info -->
    <xsl:template match="*[contains(@class,' task/info ')]//*[contains(@class,' floatfig-d/floatfig ')]" priority="4"/>

    <!-- 
     function:	substeps template
     param:	    
     return:	fo:list-block
     note:      No fn elements supposed in the steps		
     -->
    <xsl:template match="*[contains(@class, ' task/substeps ')]" mode="MODE_GET_STYLE" as="xs:string*" priority="2">
        <xsl:sequence select="'atsSubSteps'"/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' task/substeps ')]" priority="2">
        <xsl:call-template name="processSubSteps"/>
    </xsl:template>
    
    <xsl:template name="processSubSteps">
        <!-- Prefix of step -->
        <xsl:variable name="stepNumberFormat" as="xs:string+">
            <xsl:call-template name="getVarValueWithLangAsStringSequence">
                <xsl:with-param name="prmVarName" select="'Step_Number_Formats'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="numberFormat" select="ahf:getOlNumberFormat(.,$stepNumberFormat)" as="xs:string"/>
        <fo:list-block>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates>
                <xsl:with-param name="prmNumberFormat" select="$numberFormat"/>
            </xsl:apply-templates>
        </fo:list-block>
    </xsl:template>
    
    <!-- 
     function:	substeps/substep template
     param:	    prmNumberFormat
     return:	fo:list-item
     note:		
     -->
    <xsl:template match="*[contains(@class, ' task/substeps ')]/*[contains(@class,' task/substep ')]" mode="MODE_GET_STYLE" as="xs:string*" priority="2">
        <xsl:sequence select="'atsSubStepItem'"/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' task/substeps ')]/*[contains(@class,' task/substep ')]" priority="2">
        <xsl:param name="prmNumberFormat" required="yes" as="xs:string"/>
        
        <xsl:call-template name="processSubStep">
            <xsl:with-param name="prmNumberFormat" select="$prmNumberFormat"/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template name="processSubStep">
        <xsl:param name="prmNumberFormat" required="yes" as="xs:string"/>
        
        <fo:list-item>
            <!-- Set list-item attribute. -->
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <fo:list-item-label end-indent="label-end()"> 
                <fo:block>
                    <xsl:call-template name="getAttributeSetWithLang">
                        <xsl:with-param name="prmAttrSetName" select="'atsSubStepLabel'"/>
                    </xsl:call-template>
                    <xsl:number format="{$prmNumberFormat}" value="count(preceding-sibling::*[contains(@class,' topic/li ')]) + 1"/>
                </fo:block>
            </fo:list-item-label>
            <fo:list-item-body start-indent="body-start()">
                <xsl:call-template name="getAttributeSetWithLang">
                    <xsl:with-param name="prmAttrSetName" select="'atsSubStepBody'"/>
                </xsl:call-template>
                <!-- Pull info/floatfig -->
                <xsl:for-each select="*[contains(@class,' task/info ')]//*[contains(@class,' floatfig-d/floatfig ')]">
                    <xsl:choose>
                        <xsl:when test="string(@float) = ('left','right')">
                            <xsl:call-template name="processFloatFigLR"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="processFloatFigNone"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
                <fo:block>
                    <xsl:call-template name="getAttributeSetWithLang">
                        <xsl:with-param name="prmAttrSetName" select="'atsP'"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </fo:block>
            </fo:list-item-body>
        </fo:list-item>
    </xsl:template>
    
    <!-- 
     function:	stepsection template
     param:	    
     return:	fo:list-item
     note:		Stepsection appears in the steps/step-unordered. 
                However it must be formatted like section. No list number
                or bullet are needed. (2011-10-24 t.makita)
     -->
    <xsl:template match="*[contains(@class, ' task/stepsection ')]" mode="MODE_GET_STYLE" as="xs:string*" priority="2">
        <xsl:sequence select="'atsStepSection'"/>
    </xsl:template>    

    <xsl:template match="*[contains(@class, ' task/stepsection ')]" priority="2">
        <fo:list-item>
            <!-- Set list-item attribute. -->
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <fo:list-item-label> 
                <fo:block/>
            </fo:list-item-label>
            <fo:list-item-body start-indent="inherited-property-value(start-indent)">
                <fo:block>
                    <xsl:copy-of select="ahf:getAttributeSet('atsP')"/>
                    <xsl:apply-templates/>
                </fo:block>
            </fo:list-item-body>
        </fo:list-item>
    </xsl:template>
    
    <!-- 
     function:	cmd template
     param:	    
     return:	fo:inline
     note:		none
     -->
    <xsl:template match="*[contains(@class, ' task/cmd ')]" mode="MODE_GET_STYLE" as="xs:string*" priority="2">
        <xsl:sequence select="'atsCmd'"/>
    </xsl:template>    

    <xsl:template match="*[contains(@class, ' task/cmd ')]" priority="2">
        <fo:inline>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>
    
    <!-- 
     function:	info template
     param:	    
     return:	fo:block
     note:		none
     -->
    <xsl:template match="*[contains(@class, ' task/info ')]" mode="MODE_GET_STYLE" as="xs:string*" priority="2">
        <xsl:sequence select="'atsInfo'"/>
    </xsl:template>    
    
    <xsl:template match="*[contains(@class, ' task/info ')]" priority="2">
        <fo:block>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
    
    <!-- 
     function:	stepxmp template
     param:	    
     return:	fo:block
     note:		none
     -->
    <xsl:template match="*[contains(@class, ' task/stepxmp ')]" mode="MODE_GET_STYLE" as="xs:string*" priority="2">
        <xsl:sequence select="'atsStepxmp'"/>
    </xsl:template>    
    
    <xsl:template match="*[contains(@class, ' task/stepxmp ')]" priority="2">
        <fo:block>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
    
    <!-- 
     function:	choicetable template
     param:	    
     return:	fo:table
     note:		@keycol default value is defined 1 in DTD.
                MODE_GET_STYLE is defined only for choicetable in this version.
     -->
    <xsl:template match="*[contains(@class, ' task/choicetable ')]" mode="MODE_GET_STYLE" as="xs:string*" priority="2">
        <xsl:sequence select="'atsChoiceTable'"/>
    </xsl:template>    

    <xsl:template match="*[contains(@class, ' task/choicetable ')]" priority="2">
        <xsl:variable name="choiceTable" select="."/>
        <xsl:variable name="keyCol" select="ahf:getKeyCol(.)" as="xs:integer"/>
        <xsl:variable name="choiceTableAttr" as="attribute()*">
            <xsl:call-template name="getAttributeSetWithLang"/>
        </xsl:variable>
        <fo:table-and-caption>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)[name() eq 'text-align']"/>
            <fo:table>
                <xsl:copy-of select="$choiceTableAttr"/>
                <xsl:copy-of select="ahf:getDisplayAtts(.,$choiceTableAttr)"/>
                <xsl:call-template name="ahf:getUnivAtts"/>
                <xsl:copy-of select="ahf:getFoStyleAndProperty(.)[name() ne 'text-align']"/>
                <xsl:if test="exists(@relcolwidth)">
                    <xsl:copy-of select="ahf:getAttributeSet('atsChoiceTableFixed')"/>
                    <xsl:call-template name="processRelColWidth">
                        <xsl:with-param name="prmRelColWidth" select="string(@relcolwidth)"/>
                        <xsl:with-param name="prmTable" select="$choiceTable"/>
                    </xsl:call-template>
                </xsl:if>
                <xsl:choose>
                    <xsl:when test="*[contains(@class, ' task/chhead ')]">
                        <xsl:apply-templates select="*[contains(@class, ' task/chhead ')]">
                            <xsl:with-param name="prmKeyCol"   select="$keyCol"/>
                        </xsl:apply-templates>
                    </xsl:when>
                    <xsl:otherwise>
                        <fo:table-header>
                            <xsl:copy-of select="ahf:getAttributeSet('atsChhead')"/>
                            <fo:table-row>
                                <xsl:copy-of select="ahf:getAttributeSet('atsChheadRow')"/>
                                <fo:table-cell>
                                    <xsl:copy-of select="ahf:getAttributeSet('atsChoptionhd')"/>
                                    <xsl:choose>
                                        <xsl:when test="$keyCol = 1">
                                            <xsl:copy-of select="ahf:getAttributeSet('atsChKeyCol')"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:copy-of select="ahf:getAttributeSet('atsChNoKeyCol')"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    <fo:block>
                                        <xsl:call-template name="getVarValueWithLangAsText">
                                            <xsl:with-param name="prmVarName" select="'Choptionhd'"/>
                                        </xsl:call-template>
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell>
                                    <xsl:copy-of select="ahf:getAttributeSet('atsChdeschd')"/>
                                    <xsl:choose>
                                        <xsl:when test="$keyCol = 2">
                                            <xsl:copy-of select="ahf:getAttributeSet('atsChKeyCol')"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:copy-of select="ahf:getAttributeSet('atsChNoKeyCol')"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    <fo:block>
                                        <xsl:call-template name="getVarValueWithLangAsText">
                                            <xsl:with-param name="prmVarName" select="'Chdeschd'"/>
                                        </xsl:call-template>
                                    </fo:block>
                                </fo:table-cell>
                            </fo:table-row>
                        </fo:table-header>
                    </xsl:otherwise>
                </xsl:choose>
                
                <fo:table-body>
                    <xsl:copy-of select="ahf:getAttributeSet('atsChbody')"/>
                    <xsl:apply-templates select="*[contains(@class, ' task/chrow ')]">
                        <xsl:with-param name="prmKeyCol"   select="$keyCol"/>
                    </xsl:apply-templates>
                </fo:table-body>
                
            </fo:table>
        </fo:table-and-caption>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' task/chhead ')]" priority="2">
        <xsl:param name="prmKeyCol"   required="yes"  as="xs:integer"/>
    
        <fo:table-header>
            <xsl:copy-of select="ahf:getAttributeSet('atsChhead')"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <fo:table-row>
                <xsl:copy-of select="ahf:getAttributeSet('atsChheadRow')"/>
                <xsl:apply-templates>
                    <xsl:with-param name="prmKeyCol"   select="$prmKeyCol"/>
                </xsl:apply-templates>
            </fo:table-row>
        </fo:table-header>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' task/chhead ')]/*[contains(@class, ' task/choptionhd ')]" priority="2">
        <xsl:param name="prmKeyCol"   required="yes"  as="xs:integer"/>
    
        <fo:table-cell>
            <xsl:copy-of select="ahf:getAttributeSet('atsChoptionhd')"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:choose>
                <xsl:when test="$prmKeyCol = 1">
                    <xsl:copy-of select="ahf:getAttributeSet('atsChKeyCol')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="ahf:getAttributeSet('atsChNoKeyCol')"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <fo:block>
                <xsl:apply-templates/>
            </fo:block>
        </fo:table-cell>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' task/chhead ')]/*[contains(@class, ' task/chdeschd ')]" priority="2">
        <xsl:param name="prmKeyCol"   required="yes"  as="xs:integer"/>
    
        <fo:table-cell>
            <xsl:copy-of select="ahf:getAttributeSet('atsChdeschd')"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:choose>
                <xsl:when test="$prmKeyCol = 2">
                    <xsl:copy-of select="ahf:getAttributeSet('atsChKeyCol')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="ahf:getAttributeSet('atsChNoKeyCol')"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <fo:block>
                <xsl:apply-templates/>
            </fo:block>
        </fo:table-cell>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' task/chrow ')]" priority="2">
        <xsl:param name="prmKeyCol"   required="yes"  as="xs:integer"/>
    
        <fo:table-row>
            <xsl:copy-of select="ahf:getAttributeSet('atsChrow')"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates>
                <xsl:with-param name="prmKeyCol"   select="$prmKeyCol"/>
            </xsl:apply-templates>
        </fo:table-row>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' task/chrow ')]/*[contains(@class, ' task/choption ')]" priority="2">
        <xsl:param name="prmKeyCol"   required="yes"  as="xs:integer"/>
    
        <fo:table-cell>
            <xsl:copy-of select="ahf:getAttributeSet('atsChoption')"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:choose>
                <xsl:when test="$prmKeyCol = 1">
                    <xsl:copy-of select="ahf:getAttributeSet('atsChKeyCol')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="ahf:getAttributeSet('atsChNoKeyCol')"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <fo:block>
                <xsl:apply-templates/>
            </fo:block>
        </fo:table-cell>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' task/chrow ')]/*[contains(@class, ' task/chdesc ')]" priority="2">
        <xsl:param name="prmKeyCol"   required="yes"  as="xs:integer"/>
    
        <fo:table-cell>
            <xsl:copy-of select="ahf:getAttributeSet('atsChdesc')"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:choose>
                <xsl:when test="$prmKeyCol eq 2">
                    <xsl:copy-of select="ahf:getAttributeSet('atsChKeyCol')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="ahf:getAttributeSet('atsChNoKeyCol')"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <fo:block>
                <xsl:apply-templates/>
            </fo:block>
        </fo:table-cell>
    </xsl:template>
    
    <!-- 
     function:	stepresult template
     param:	    
     return:	fo:block
     note:		none
     -->
    <xsl:template match="*[contains(@class, ' task/stepresult ')]" mode="MODE_GET_STYLE" as="xs:string*" priority="2">
        <xsl:sequence select="'atsStepresult'"/>
    </xsl:template>    
    
    <xsl:template match="*[contains(@class, ' task/stepresult ')]" priority="2">
        <fo:block>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
    
    <!-- 
     function:	tutorialinfo template
     param:	    
     return:	fo:block
     note:		none
     -->
    <xsl:template match="*[contains(@class, ' task/tutorialinfo ')]" mode="MODE_GET_STYLE" as="xs:string*" priority="2">
        <xsl:sequence select="'atsTutorialinfo'"/>
    </xsl:template>    
    
    <xsl:template match="*[contains(@class, ' task/tutorialinfo ')]" priority="2">
        <fo:block>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
    
    
    <!-- 
     function:	result template
     param:	    
     return:	fo:block
     note:		none
     -->
    <xsl:template match="*[contains(@class, ' task/result ')]" mode="MODE_GET_STYLE" as="xs:string*" priority="2">
        <xsl:sequence select="'atsResult'"/>
    </xsl:template>    

    <xsl:template match="*[contains(@class, ' task/result ')]" priority="2">
        <fo:block>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
    
    <!-- 
     function:	postreq template
     param:	    
     return:	fo:block
     note:		none
     -->
    <xsl:template match="*[contains(@class, ' task/postreq ')]" mode="MODE_GET_STYLE" as="xs:string*" priority="2">
        <xsl:sequence select="'atsPostreq'"/>
    </xsl:template>    

    <xsl:template match="*[contains(@class, ' task/postreq ')]" priority="2">
        <fo:block>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>

</xsl:stylesheet>