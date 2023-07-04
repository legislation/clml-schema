
# Legislation schema

The schemas are intended to describe UK Legislation.

Crown copyright 2018-2023


## Release notes

### Version 2.6

Release date: 2023-06-02

* LEGDEV-5195: added new schema publicationLog.xsd, for the update feed (https://www.legislation.gov.uk/update/data.feed)
* LEGDEV-5195: Added "Print" attribute which specified if PDFs are print or non-print

### Version 2.5

Release date: 2022-12-02

* LEGDEV-3403 Extend the schema to add in reference to the new Welsh attributes (WelshApplied and WelshRequiresApplied)
* LEGDEV-4101 Remove duplicate 'ScottishStatutoryInstrumentLocal' entry
* LEGDEV-3885 Add support for changes wrapping MathML in Formula elements
* LEGDEV-2369 Fixed issue with checkout of tables in XMetaL 16

### Version 2.4

Release date: 2022-08-10

* Mainly a schema documentation work, adding & updating annotations for various elements, attributes and general description, in different files.
* LEGDEV-1125 - Part of this, removed duplicated RefsLinkType from schemaCommonNonEdit.xsd & fragment.xsd files. And moved RefsLinkType into SchemaLegsilationCommonAttributes.xsd file.


### Version 2.3

Release date: 2020-12-14

* Issue 171209490 - new attribute values supported for EU Minor document classification in BlockAmendment (with refactoring and re-use of MinorType)
* Issue 172129366 - Added CommonSubAttributes to Division 


### Version 2.2

Release date: 2020-12-13

* New schema version numbering scheme introduced (see below)
* New schema release documentation (this file and generated documentation)
* New and updated schema documentation in all files (as text or html elements within xsd:documentation)
* Issue 171209490 - Minor document classification in BlockAmendment refactored for re-use of MinorType (in preparation for EU values to be added in v2.3)
* Issue 171488633 - the legislation.xsd schema can now be used for validation with MSXML4 or .Net validators (changes to atom.xsd and xml.xsd)
* Issue 161958070 - changed the model for the attributes on ukm:Correction to have stricter validation rules
* Issue 171578804 - renamed TSOMetadata to LegislationMetadata
* The master copy of XMetaL configuration files are not the ones in the schema folder so we no longer store XMetaL files in the schema folder. The updated RLD file is for now placed in the XMetaL folder. 
* Change #172451773 Deleted top-level schema schemaLegislationBase-v1-0.xsd as it is not used any more. The XSLT LegXSD2PubXSD.xsl has been modified to create a TSO namespace version (from legislation.xsd) to deploy to legacy systems.
* Change #172575932 Remove top level schema definition of DocumentMainType (no longer required) and move to schemaCommon.xsd

### Version 2.1

Release date: 2020-05-05

* Issue 171654037 - Effect ukm:InForce Qualification attribute now validates against a set of approved string values (including empty string for historical reasons)
* Issue 171578804 - renamed TSOMetadata to LegislationMetadata
* Issue 171841757 - changes for ASC project (changed DocumentMainTypeBasic to add "WelshParliamentAct" and added "WelshParliament" to Laid values) as a result of http://www.legislation.gov.uk/anaw/2020/1/enacted#section-3
* Issue 171599021 - removed default values for FragmentAttributes and ContentsAttributes
* The master copy of XMetaL configuration files are not the ones in the schema folder so we no longer store XMetaL files in the schema folder. The updated RLD file is for now placed in the XMetaL folder. 


## Schema documentation

A package of schema documentation is be delivered with every release.  The documentation is delivered as a hyperlinked HTML application comprising an integrated reference guide and user guide.  This will be delivered online.

The source files for the documentation are the schema files themselves plus the XML, XHTML and images in the schemaDoc/CLMLFiles folder.

## Top-level schemas

The following schema (from the "schema" folder") are "top-level" schema that should be used to validate various types of legislative documents.

* legislation.xsd - schema for Primary and Secondary UK Legislation data sets including those available from legislation.gov.uk and from the bulk downloads site http://leggovuk.s3-website-eu-west-1.amazonaws.com
* en.xsd - schema for Explanatory Notes and Explanatory Memoranda.
* impactAssessment.xsd - schema for UK Impact Assessments.
* fragment.xsd - schema for subsets of Primary and Secondary UK Legislation data files during the editing process.
* publicationLog.xsd - schema for the Legislation.gov.uk update feed (https://www.legislation.gov.uk/update/data.feed)

## Schema versioning and documentation of change

If a change is made to the schema that breaks old data or significantly changes the meaning of existing semantics then the schema versions will change in such a way that old data can point to old schema and new data to new schema. This is to be avoided if at all possible (as has been the case with legislation). The change would be reflected by a change to the namespace (by adding a version). This would invalidate all old data and require updates to all systems/scripts and schema modules. This is to be avoided unless entirely necessary!

As with most software releases, the major version will change when there is a significant re-issue of a whole schema with new features and/or re-modelling. Small improvements and or bug fixes are shown with a minor version number. e.g. "2.3" has major version of "2" and minor of "3" and The next minor version would be "2.4" and the next major version would be "3.0".

The schema version number will be recorded in the version attribute on the schema. We will only update a schema modules' version number when they themselves change for a minor update - this makes it easier for developers to know what modules have changed. We will also increment the version number of the top-level schemas (see above) even if they did not change as their content may have changed as a result of a change to the included schema modules and it will help developers know what version of the schema they are dealing with. We will of-course also update the top-level schemas version if they themselves change. When we issue a major release (version 3.0 is next) we update all TSO schema module versions to match the major number.
All of these changes will also trigger a change to the schema's dcq:modified date element in the Dublin Core Metadata.

The schema developer will document each change (made for a bug fix or new feature) at the top of the schema file with a version number BUT if a number of schema changes are being made over a period of a few weeks for a given RELEASE of the schema then it is likely that a number of changes within a single schema file will have the same version number (as they are part of the same release). The change log in BitBucket will supply those with access to a more granular "what individual change happened on what date WITHIN a given release" and so no there is no requirement to add additional point point release numbers.

Schema developers should always include a file level xsd:documentation history comment which matches the change to a specific version. This provides context for changes for those who cannot access the Bitbucket repository.

Any development that effects a change in the currently released data model or its meaning should be documented using xs:documentation at element/type level.
This change will then be reflected in both dynamically generated documentation but also must be changed by the developer in any static information that supplements it (in the new documentation set to be developed soon).
When a release is made, the new version of the documentation will be generated and released.

Any code level (as opposed to file level) developer comment that describes a change that does not affect the data model should be recorded using an &lt;!-- XML comment --> and should link the change to the appropriate Pivotal issue. 

Any change will be agreed in advance of release with TNA Schema Change Board.

Any change to the schema will be applied to the unified-schema in Bitbucket https://bitbucket.org/tsoltd/unified-master-schema/src/master/

Schemas versions will be released formally and distributed automatically to all systems. 
