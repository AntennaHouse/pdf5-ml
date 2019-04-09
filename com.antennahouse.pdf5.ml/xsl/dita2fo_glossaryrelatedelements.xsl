<?xml version='1.0' encoding="UTF-8" ?>
<!--
****************************************************************
DITA to XSL-FO Stylesheet 
Module: Glossary related elements stylesheet
Copyright © 2009-2010 Antenna House, Inc. All rights reserved.
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

    <!-- 
     function:    abbreviated-form template
     param:       prmTopicRef
     return:      fo:basic-link
     note:        SPEC; DITA 1.3
                  http://docs.oasis-open.org/dita/dita/v1.3/errata02/os/complete/part3-all-inclusive/langRef/technicalContent/abbreviated-form.html#abbreviated-form
                  For instance, a process composing a book deliverable might emit the surface form of a term on the first reference to the <glossentry> topic 
                  within the book or for every reference within a copyright or a warranty-related warning. 
                  A process generating an online page might emit the surface form as a hover tooltip on every instance of the term.
                  
                  Change the abbreviated-form count range to document level (with map & topic).
                  Implement $prmGetContent processing.
                  2019-04-02 t.makita
     -->
    <xsl:template match="*[contains(@class,' abbrev-d/abbreviated-form ')]" mode="MODE_GET_STYLE" as="xs:string*" priority="2">
        <xsl:sequence select="'atsXref'"/>
    </xsl:template>

    <xsl:template match="*[contains(@class,' abbrev-d/abbreviated-form ')]" priority="2">
        <xsl:param name="prmTopicRef" tunnel="yes" required="yes"  as="element()?"/>
        <xsl:param name="prmGetContent" required="no" tunnel="yes" as="xs:boolean" select="false()"/>
        
        <xsl:variable name="abbreviatedForm" as="element()" select="."/>
        <xsl:variable name="href" as="xs:string" select="string(@href)"/>
        <xsl:variable name="destAttr" as="attribute()*">
            <xsl:call-template name="getDestinationAttr">
                <xsl:with-param name="prmHref" select="$href"/>
                <xsl:with-param name="prmElem" select="$abbreviatedForm"/>
                <xsl:with-param name="prmTopicRef" select="$prmTopicRef"/>
            </xsl:call-template>    
        </xsl:variable>
        <xsl:variable name="abbreviatedFormCount" as="xs:integer">
            <xsl:number select="."
                level="any"
                count="*[contains(@class,' abbrev-d/abbreviated-form ')][string(@href) eq $href]"
                from="/*"  use-when="starts-with(system-property('ot.version'),'2') or starts-with(system-property('ot.version'),'1')"/>
            <xsl:number select="."
                level="any"
                count="*[contains(@class,' abbrev-d/abbreviated-form ')][string(@href) eq $href]"
                from="$root"  use-when="not(starts-with(system-property('ot.version'),'2') or starts-with(system-property('ot.version'),'1'))"/>
        </xsl:variable>
        <xsl:variable name="topicElement" as="element()?" select="ahf:getTopicFromHref(substring-after($href, '#'))"/>

        <xsl:choose>
            <xsl:when test="empty($topicElement)">
                <xsl:call-template name="warningContinue">
                    <xsl:with-param name="prmMes" select="ahf:replace($stMes092,('%keyref','%href','%file'),(string(@keyref),$href,string(@xtrf)))"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="not(contains($topicElement/@class,' glossentry/glossentry '))">
                <fo:basic-link>
                    <xsl:copy-of select="$destAttr"/>
                    <xsl:choose>
                        <xsl:when test="$prmGetContent">
                            <xsl:call-template name="getAttributeSetWithLang">
                                <xsl:with-param name="prmAttrSetName" select="'atsXref'"/>
                            </xsl:call-template>
                            <xsl:copy-of select="ahf:getUnivAtts(.,(),false())"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="getAttributeSetWithLang">
                                <xsl:with-param name="prmAttrSetName" select="'atsXref'"/>
                                <xsl:with-param name="prmElem" select="$topicElement/*[contains(@class, ' topic/title ')]"/>
                                <xsl:with-param name="prmDoInherit" select="true()"/>
                            </xsl:call-template>
                            <xsl:call-template name="ahf:getUnivAtts"/>
                            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:apply-templates select="$topicElement/*[contains(@class, ' topic/title ')]" mode="GET_CONTENTS"/>
                </fo:basic-link>
            </xsl:when>
            <xsl:when test="$abbreviatedFormCount le 1">
                <xsl:variable name="glossSurfaceFormElem"
                              select="$topicElement
                                     /*[contains(@class, ' glossentry/glossBody ')]
                                     /*[contains(@class, ' glossentry/glossSurfaceForm ')][1]"
                              as="element()?"/>
                <xsl:choose>
                    <xsl:when test="exists($glossSurfaceFormElem)">
                        <fo:basic-link>
                            <xsl:copy-of select="$destAttr"/>
                            <xsl:choose>
                                <xsl:when test="$prmGetContent">
                                    <xsl:call-template name="getAttributeSetWithLang">
                                        <xsl:with-param name="prmAttrSetName" select="'atsXref'"/>
                                    </xsl:call-template>
                                    <xsl:copy-of select="ahf:getUnivAtts(.,(),false())"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:call-template name="getAttributeSetWithLang">
                                        <xsl:with-param name="prmAttrSetName" select="'atsXref'"/>
                                        <xsl:with-param name="prmElem" select="$glossSurfaceFormElem"/>
                                        <xsl:with-param name="prmDoInherit" select="true()"/>
                                    </xsl:call-template>
                                    <xsl:call-template name="ahf:getUnivAtts"/>
                                    <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:apply-templates select="$glossSurfaceFormElem" mode="GET_CONTENTS"/>
                        </fo:basic-link>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="glossTerm" as="element()" select="$topicElement/*[contains(@class, ' glossentry/glossterm ')][1]"/>
                        <fo:basic-link>
                            <xsl:copy-of select="$destAttr"/>
                            <xsl:choose>
                                <xsl:when test="$prmGetContent">
                                    <xsl:call-template name="getAttributeSetWithLang">
                                        <xsl:with-param name="prmAttrSetName" select="'atsXref'"/>
                                    </xsl:call-template>
                                    <xsl:copy-of select="ahf:getUnivAtts(.,(),false())"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:call-template name="getAttributeSetWithLang">
                                        <xsl:with-param name="prmAttrSetName" select="'atsXref'"/>
                                        <xsl:with-param name="prmElem" select="$glossTerm"/>
                                        <xsl:with-param name="prmDoInherit" select="true()"/>
                                    </xsl:call-template>
                                    <xsl:call-template name="ahf:getUnivAtts"/>
                                    <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:apply-templates select="$glossTerm" mode="GET_CONTENTS"/>
                        </fo:basic-link>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="glossAltElem" as="element()">
                    <xsl:variable name="glossAcronymElem"
                                  select="$topicElement
                                        /*[contains(@class, ' glossentry/glossBody ')]
                                        /*[contains(@class, ' glossentry/glossAlt ')]
                                          [ahf:checkGlossStatus(.)]
                                        /*[contains(@class, ' glossentry/glossAcronym ')]"
                                  as="element()*"/>
                    <xsl:variable name="glossglossAbbreviationElem"
                                  select="$topicElement
                                        /*[contains(@class, ' glossentry/glossBody ')]
                                        /*[contains(@class, ' glossentry/glossAlt ')]
                                          [ahf:checkGlossStatus(.)]
                                        /*[contains(@class, ' glossentry/glossAbbreviation ')]"
                                  as="element()*"/>
                    <xsl:choose>
                        <xsl:when test="exists($glossAcronymElem)">
                            <xsl:sequence select="$glossAcronymElem[1]"/>
                        </xsl:when>
                        <xsl:when test="exists($glossglossAbbreviationElem)">
                            <xsl:sequence select="$glossglossAbbreviationElem[1]"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="$topicElement/*[contains(@class, ' glossentry/glossterm ')]"/>
                        </xsl:otherwise>
    			    </xsl:choose>
                </xsl:variable>
                <fo:basic-link>
                    <xsl:copy-of select="$destAttr"/>
                    <xsl:choose>
                        <xsl:when test="$prmGetContent">
                            <xsl:call-template name="getAttributeSetWithLang">
                                <xsl:with-param name="prmAttrSetName" select="'atsXref'"/>
                            </xsl:call-template>
                            <xsl:copy-of select="ahf:getUnivAtts(.,(),false())"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="getAttributeSetWithLang">
                                <xsl:with-param name="prmAttrSetName" select="'atsXref'"/>
                                <xsl:with-param name="prmElem" select="$glossAltElem"/>
                                <xsl:with-param name="prmDoInherit" select="true()"/>
                            </xsl:call-template>
                            <xsl:call-template name="ahf:getUnivAtts"/>
                            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:apply-templates select="$glossAltElem" mode="GET_CONTENTS"/>
                </fo:basic-link>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:function name="ahf:checkGlossStatus" as="xs:boolean">
        <xsl:param name="prmGlossAlt" as="element()"/>
        <xsl:choose>
            <xsl:when test="$prmGlossAlt/*[contains(@class, ' glossentry/glossStatus ')]/@value eq 'prohibited'">
                <xsl:sequence select="false()"/>
            </xsl:when>
            <xsl:when test="$prmGlossAlt/*[contains(@class, ' glossentry/glossStatus ')]/@value eq 'obsolute'">
                <xsl:sequence select="false()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="true()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

</xsl:stylesheet>