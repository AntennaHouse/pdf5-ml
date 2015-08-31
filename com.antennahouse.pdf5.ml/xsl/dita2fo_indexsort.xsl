<?xml version="1.0" encoding="UTF-8"?>
<!--
*******************************************************************
DITA to XSL-FO Stylesheet
Module: Index sorting template (Does not use I18n Index Library)
Copyright © 2009-2012 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL    : http://www.antennahouse.com/
E-mail : info@antennahouse.com
*******************************************************************
-->
<xsl:stylesheet version="2.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
 xmlns:myFunGT="my:myFunGT"
 xmlns:fxslDefaultGT="f:fxslDefaultGT"
 exclude-result-prefixes="myFunGT"
>

    <!-- ======================================================================== 
        This code is converterd from XSLT1.0 to XSLT 2.0 from following example:
        [xsl] Sorting with unknown number of sort keys (Was: Re: Sort question)
        http://www.biglist.com/lists/xsl-list/archives/200303/msg00007.html
        Thank you Dimitre Novatchev.
        =========================================================================
    -->
    
    <!-- Saxon 9 collation string -->
    <xsl:variable name="cCollationURI" select="ahf:getVarValue('cCollationURI')" as="xs:string"/>
    
    <xsl:template name="indexSort" as="document-node()">
        <xsl:param name="prmIndexterm" as="document-node()"/>
        <xsl:call-template name="hSort">
            <xsl:with-param name="pList" select="$prmIndexterm/*"/>
            <xsl:with-param name="pFunGT"
                select="document('')/*/myFunGT:*[1]"/>
        </xsl:call-template> 
    </xsl:template>
    
    <myFunGT:myFunGT/>
    <xsl:template match="myFunGT:*" as="xs:integer">
        <xsl:param name="arg1" as="element()" required="yes"/>
        <xsl:param name="arg2" as="element()" required="yes"/>
        
        <xsl:variable name="vcnt1" select="count($arg1/key)"/>
        <xsl:variable name="vcnt2" select="count($arg2/key)"/>
        
        <xsl:variable name="vComnLength" as="xs:integer"
            select="$vcnt1 * (if ($vcnt2 ge $vcnt1) then 1 else 0)
                    +
                    $vcnt2 * (if ($vcnt1 gt $vcnt2) then 1 else 0)"/>
        
        <xsl:call-template name="compareStringList">
            <xsl:with-param name="plistStr1"
                select="$arg1/key[position() le $vComnLength]"/>
            <xsl:with-param name="plistStr2"
                select="$arg2/key[position() le $vComnLength]"/>
            <xsl:with-param name="pLength" select="$vComnLength"/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template name="compareStringList" as="xs:integer">
        <xsl:param name="plistStr1" as="xs:string*" required="yes"/>
        <xsl:param name="plistStr2" as="xs:string*" required="yes"/>
        <xsl:param name="pLength"   as="xs:integer" required="yes"/>
        
        <xsl:choose>
            <xsl:when test="$pLength gt 0">
                <xsl:variable name="vComp" as="xs:integer">
                    <xsl:call-template name="node-strComp">
                        <xsl:with-param name="n1" select="$plistStr1[1]"/>
                        <xsl:with-param name="n2" select="$plistStr2[1]"/>
                    </xsl:call-template>
                </xsl:variable>
                
                <xsl:choose>
                    <xsl:when test="$vComp ne 0">
                        <xsl:sequence select="$vComp"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="compareStringList">
                            <xsl:with-param name="plistStr1"
                                select="$plistStr1[position() gt 1]"/>
                            <xsl:with-param name="plistStr2"
                                select="$plistStr2[position() gt 1]"/>
                            <xsl:with-param name="pLength" select="$pLength - 1"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="0"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
        
    <xsl:template name="node-strComp" as="xs:integer">
        <xsl:param name="n1" as="xs:string?" required="yes"/>
        <xsl:param name="n2" as="xs:string?" required="yes"/>
        <!--xsl:variable name="result" as="xs:integer" select="compare($n1,$n2,$cCollationURI)"/>
        <xsl:message select="'$n1=',$n1,'$n2=',$n2,'$result=',string($result), '$cCollationURI=',$cCollationURI"></xsl:message-->
        <xsl:sequence select="compare($n1,$n2,$cCollationURI)"/>
        <!--xsl:choose>
            <xsl:when test="string($n1)=string($n2)">0</xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="$n1,$n2">
                    <xsl:sort select="." lang="$documentLang"/>
                    <xsl:if test="position()=1">
                        <xsl:choose>
                            <xsl:when test="string(.) = string($n1)">-1</xsl:when>
                            <xsl:otherwise>1</xsl:otherwise>
                        </xsl:choose>
                    </xsl:if>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose-->
    </xsl:template>
    
    <xsl:template name="hSort" as="document-node()">
        <xsl:param name="pList" as="element()*" required="yes"/>
        <xsl:param name="pFunGT" required="no" select="document('')/*/fxslDefaultGT:*[1]" />
        
        <xsl:variable name="vLength" as="xs:integer" select="count($pList)"/>
        <xsl:choose>
            <xsl:when test="$vLength > 1">
                <xsl:variable name="vrtfH1Sorted" as="document-node()">
                    <xsl:call-template name="hSort">
                        <xsl:with-param name="pList" select="$pList[position() le
                            $vLength div 2]"/>
                        <xsl:with-param name="pFunGT" select="$pFunGT"/>
                    </xsl:call-template>
                </xsl:variable>
                
                <xsl:variable name="vrtfH2Sorted" as="document-node()">
                    <xsl:call-template name="hSort">
                        <xsl:with-param name="pList" select="$pList[position() gt
                            $vLength div 2]"/>
                        <xsl:with-param name="pFunGT" select="$pFunGT"/>
                    </xsl:call-template>
                </xsl:variable>
                
                <xsl:call-template name="merge">
                    <xsl:with-param name="pList1"
                        select="$vrtfH1Sorted/*"/>
                    <xsl:with-param name="pList2"
                        select="$vrtfH2Sorted/*"/>
                    <xsl:with-param name="pFunGT" select="$pFunGT"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$vLength = 1">
                <xsl:document>
                    <xsl:copy-of select="$pList[1]"/>    
                </xsl:document>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="merge" as="document-node()">
        <xsl:param name="pList1" as="element()*" required="yes"/>
        <xsl:param name="pList2" as="element()*" required="yes"/>
        <xsl:param name="pFunGT" select="/.."/>
        
        <xsl:choose>
            <xsl:when test="empty($pList1) or empty($pList2)">
                <xsl:document>
                    <xsl:copy-of select="$pList1 | $pList2"/>    
                </xsl:document>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="vGT" as="xs:integer">
                    <xsl:apply-templates select="$pFunGT">
                        <xsl:with-param name="arg1" select="$pList1[1]"/>
                        <xsl:with-param name="arg2" select="$pList2[1]"/>
                    </xsl:apply-templates>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="$vGT le 0">
                        <xsl:variable name="rest" as="document-node()">
                            <xsl:call-template name="merge">
                                <xsl:with-param name="pList1" select="$pList1[position() gt 1]"/>
                                <xsl:with-param name="pList2" select="$pList2"/>
                                <xsl:with-param name="pFunGT" select="$pFunGT"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:document>
                            <xsl:copy-of select="$pList1[1]"/>
                            <xsl:copy-of select="$rest/*"/>
                        </xsl:document>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="rest" as="document-node()">
                            <xsl:call-template name="merge">
                                <xsl:with-param name="pList2" select="$pList2[position() gt 1]"/>
                                <xsl:with-param name="pList1" select="$pList1"/>
                                <xsl:with-param name="pFunGT" select="$pFunGT"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:document>
                            <xsl:copy-of select="$pList2[1]"/>    
                            <xsl:copy-of select="$rest/*"/>
                        </xsl:document>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <fxslDefaultGT:fxslDefaultGT/>
    <xsl:template match="fxslDefaultGT:*" as="xs:integer">
        <xsl:param name="arg1" as="xs:string?" required="yes"/>
        <xsl:param name="arg2" as="xs:string?" required="yes"/>
        
        <!--xsl:if test="$arg1 > $arg2">1</xsl:if-->
        <xsl:sequence select="compare($arg1,$arg2)"/>
    </xsl:template>

</xsl:stylesheet>
