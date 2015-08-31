<?xml version="1.0" encoding="UTF-8" ?>
<!--
****************************************************************
DITA to XSL-FO Stylesheet
Module: Stylesheet global variables.
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
    >
    
    <!-- *************************************** 
            Document variables override example
         ***************************************-->
    <!-- Book library -->
    <xsl:variable name="bookLibrary" as="node()*">
        <xsl:value-of select="'&lt; Dummy Book Library For Acme Corporation&gt;'"/>
    </xsl:variable>
    
    <!-- Title -->
    <xsl:variable name="bookTitle" as="node()*">
        <xsl:value-of select="'&lt; Dummy Book Title For Acme Corporation&gt;'"/>
    </xsl:variable>
    
    <!-- Alt Title -->
    <xsl:variable name="bookAltTitle" as="node()*">
        <xsl:value-of select="'&lt; Dummy Alt Book Title For Acme Corporation&gt;'"/>
    </xsl:variable>
    
</xsl:stylesheet>
