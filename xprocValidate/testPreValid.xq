<?xml version="1.0" encoding="UTF-8"?>
<c:query xmlns:c="http://www.w3.org/ns/xproc-step">
    <![CDATA[
    declare namespace leg="http://www.legislation.gov.uk/namespaces/legislation";
declare namespace ukm="http://www.legislation.gov.uk/namespaces/metadata";
declare namespace dc="http://purl.org/dc/elements/1.1/";
declare namespace atom="http://www.w3.org/2005/Atom";
declare namespace h="http://www.w3.org/1999/xhtml";
declare default element namespace "http://www.legislation.gov.uk/namespaces/legislation";

declare variable $doc as node() := /Legislation[ukm:Metadata/dc:identifier='http://www.legislation.gov.uk/anaw/2012/1/enacted'];
(: for $i in $doc return($i) :)

let $rootname := name($doc)
return 
  element { $rootname } { 
    $doc/@*,
    element { "ukm:Metadata" } {
        $doc/ukm:Metadata/*[following-sibling::dc:title],
        (: make the title invalid as a test :)
        element { "dc:title" } {
          $doc/ukm:Metadata/dc:title,
          element { "BROKEN" } {
          }
        },
        $doc/ukm:Metadata/*[preceding-sibling::dc:title]
    },
    $doc/*[not(self::ukm:Metadata)]   
  }
   


    ]]>
</c:query>