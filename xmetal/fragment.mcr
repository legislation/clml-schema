<?xml version="1.0" encoding="UTF-16"?>
<!DOCTYPE MACROS SYSTEM "macros.dtd">
<MACROS>

<MACRO name="On_Macro_File_Load" key="" lang="JScript" hide="true"><![CDATA[
	// every time you change the any code in the Macro File Load, please close XMetaL and open again

	// To get amendment URI	 from the resource tab.
	function GetSelectedAmendmentUri()
	{
		var taskCtrl = ResourceManager.ControlInTab("Tasks");
		if (taskCtrl == null)	
			Application.Alert("The task control is not installed");
		else 
		{
			var selectedAmendmentUri = taskCtrl.SelectedAmendmentUri;
			if (selectedAmendmentUri == "") 
			{
				Application.Alert("No amendment has been selected in the task tree.");
			}
			else 
			{	
				return selectedAmendmentUri;
			}
		}
		
		return "";
	}
	
	//Get the source URI.
	function GetSourceUri()
	{
		var sourceUri = "";
		var sourceNodeList = ActiveDocument.getNodesByXPath("//dc:source");
		if (sourceNodeList != null  && sourceNodeList.Length>0) 
		{ // source node list exists
			var sourceNode = sourceNodeList.item(0);
			
			if (sourceNode.childNodes.length >0)  // getting the text node
				sourceUri = sourceNode.childNodes.item(0).nodeValue;			
		}		
		
		return sourceUri;
	}	
	
	//Get the PI version. Not sure use of this function
	function GetPITVersion()
	{
		
		var sourceUri = GetSourceUri();
		var sourceUriSplits = sourceUri.split("/");
		var pitVersion = sourceUriSplits[sourceUriSplits.length-1];
		var correction = sourceUri.indexOf("task/correct");
		if (pitVersion == "high-level-amends" || pitVersion == "blanket-amends" || pitVersion == "welsh" || correction != -1)
			pitVersion = sourceUriSplits[sourceUriSplits.length-2];
		return pitVersion;Application.Alert(pitVersion);
	}		
	
	//Get the PI version. Not sure use of this function
	function SetPITVersionInCurrentSelection()
	{
		var range = Selection.Duplicate;
		range.Select();
		for (var i=0;i<100;i++)  // 100 is the imaginory number of items copied in the inserting or substitution
		{
			if (range.NodeItem(i) != null)
			{
				Selection.SelectNodeContents(range.NodeItem(i));
				var containerInnerName = Selection.ContainerName;
				containerInnerName = containerInnerName.replace("leg:", "");
				Selection.ElementAttributeNS("", "RestrictStartDate", "http://www.legislation.gov.uk/namespaces/legislation", containerInnerName, 0) = GetPITVersion();
			}
			else 
				break;
		}	
	}
	
	//Set the PIT version for textual amendments
	function SetPITVersionForTextualAmendments(changeId, changeType)
	{
		//Find node where PIT version is set - either P1group, P1, Tabular or in rare cases Part, Schedule, Chapter or Prelims
		SetNodePITVersion("//ukl:PrimaryPrelims[not(@Status='Prospective') and not(ancestor::ukl:BlockAmendment) and descendant::*[@ChangeId='" +  changeId + "']]");
		SetNodePITVersion("//ukl:EUPrelims[not(@Status='Prospective') and not(ancestor::ukl:BlockAmendment) and descendant::*[@ChangeId='" +  changeId + "']]");
		SetNodePITVersion("//ukl:SecondaryPrelims[not(@Status='Prospective') and not(ancestor::ukl:BlockAmendment) and descendant::*[@ChangeId='" +  changeId + "']]");
		SetNodePITVersion("//ukl:Part[not(@Status='Prospective') and not(ancestor::ukl:BlockAmendment) and (child::*/*[@ChangeId='" +  changeId + "'] or (preceding-sibling::ukl:Part/*/*[@ChangeId='" +  changeId + "' and @Mark='Start'] and following-sibling::ukl:Part/descendant::*[@ChangeId='" +  changeId + "' and @Mark='End']) or descendant::ukl:P/descendant::*[@ChangeId='" +  changeId + "'])]");
		SetNodePITVersion("//ukl:EUPart[not(@Status='Prospective') and not(ancestor::ukl:BlockAmendment) and (child::*/*[@ChangeId='" +  changeId + "'] or (preceding-sibling::ukl:EUPart/*/*[@ChangeId='" +  changeId + "' and @Mark='Start'] and following-sibling::ukl:EUPart/descendant::*[@ChangeId='" +  changeId + "' and @Mark='End']) or descendant::ukl:P/descendant::*[@ChangeId='" +  changeId + "'])]");
		SetNodePITVersion("//ukl:EUTitle[not(@Status='Prospective') and not(ancestor::ukl:BlockAmendment) and (child::*/*[@ChangeId='" +  changeId + "'] or (preceding-sibling::ukl:EUTitle/*/*[@ChangeId='" +  changeId + "' and @Mark='Start'] and following-sibling::ukl:EUTitle/descendant::*[@ChangeId='" +  changeId + "' and @Mark='End']) or descendant::ukl:P/descendant::*[@ChangeId='" +  changeId + "'])]");
		SetNodePITVersion("//ukl:Schedule[not(@Status='Prospective') and not(ancestor::ukl:BlockAmendment) and (child::*/*/*[@ChangeId='" +  changeId + "'] or child::*/*[@ChangeId='" +  changeId + "'] or (preceding-sibling::ukl:Schedule/*/*/*[@ChangeId='" +  changeId + "' and @Mark='Start'] and following-sibling::ukl:Schedule/descendant::*[@ChangeId='" +  changeId + "' and @Mark='End']) or (preceding-sibling::ukl:Schedule/*/*[@ChangeId='" +  changeId + "' and @Mark='Start'] and following-sibling::ukl:Schedule/descendant::*[@ChangeId='" +  changeId + "' and @Mark='End']) or descendant::ukl:P/descendant::*[@ChangeId='" +  changeId + "'])]");
		SetNodePITVersion("//ukl:Chapter[not(@Status='Prospective') and not(ancestor::ukl:BlockAmendment) and (child::*/*[@ChangeId='" +  changeId + "'] or (preceding-sibling::ukl:Chapter/*/*[@ChangeId='" +  changeId + "' and @Mark='Start'] and following-sibling::ukl:Chapter/descendant::*[@ChangeId='" +  changeId + "' and @Mark='End']) or descendant::ukl:P/descendant::*[@ChangeId='" +  changeId + "'])]");
		SetNodePITVersion("//ukl:EUChapter[not(@Status='Prospective') and not(ancestor::ukl:BlockAmendment) and (child::*/*[@ChangeId='" +  changeId + "'] or (preceding-sibling::ukl:EUChapter/*/*[@ChangeId='" +  changeId + "' and @Mark='Start'] and following-sibling::ukl:EUChapter/descendant::*[@ChangeId='" +  changeId + "' and @Mark='End']) or descendant::ukl:P/descendant::*[@ChangeId='" +  changeId + "'])]");
		SetNodePITVersion("//ukl:EUSection[not(@Status='Prospective') and not(ancestor::ukl:BlockAmendment) and (child::*/*[@ChangeId='" +  changeId + "'] or (preceding-sibling::ukl:EUSection/*/*[@ChangeId='" +  changeId + "' and @Mark='Start'] and following-sibling::ukl:EUSection/descendant::*[@ChangeId='" +  changeId + "' and @Mark='End']) or descendant::ukl:P/descendant::*[@ChangeId='" +  changeId + "'])]");
		SetNodePITVersion("//ukl:EUSubsection[not(@Status='Prospective') and not(ancestor::ukl:BlockAmendment) and (child::*/*[@ChangeId='" +  changeId + "'] or (preceding-sibling::ukl:EUSubsection/*/*[@ChangeId='" +  changeId + "' and @Mark='Start'] and following-sibling::ukl:EUSubsection/descendant::*[@ChangeId='" +  changeId + "' and @Mark='End']) or descendant::ukl:P/descendant::*[@ChangeId='" +  changeId + "'])]");
		SetNodePITVersion("//ukl:Division[not(@Status='Prospective') and not(ancestor::ukl:BlockAmendment) and (child::*/*[@ChangeId='" +  changeId + "'] or (preceding-sibling::ukl:Division/*/*[@ChangeId='" +  changeId + "' and @Mark='Start'] and following-sibling::ukl:Division/descendant::*[@ChangeId='" +  changeId + "' and @Mark='End']) or descendant::ukl:P/descendant::*[@ChangeId='" +  changeId + "'])]");
		
		SetNodePITVersion("//ukl:P1group[not(@Status='Prospective') and not(ancestor::ukl:BlockAmendment) and (descendant::*[@ChangeId='" +  changeId + "'] or (preceding-sibling::ukl:P1group/descendant::*[@ChangeId='" +  changeId + "' and @Mark='Start'] and following-sibling::ukl:P1group/descendant::*[@ChangeId='" +  changeId + "' and @Mark='End']))]");
		SetNodePITVersion("//ukl:P1[not(@Status='Prospective') and not(ancestor::ukl:BlockAmendment) and not(parent::ukl:P1group) and (descendant::*[@ChangeId='" + changeId + "'] or (preceding-sibling::ukl:P1/descendant::*[@ChangeId='" +  changeId + "' and @Mark='Start'] and following-sibling::ukl:P1/descendant::*[@ChangeId='" +  changeId + "' and @Mark='End']))]");
		SetNodePITVersion("//ukl:P[@id and not(@Status='Prospective') and not(ancestor::ukl:BlockAmendment) and not(parent::ukl:P1group) and (descendant::*[@ChangeId='" + changeId + "'] or (preceding-sibling::ukl:P/descendant::*[@ChangeId='" +  changeId + "' and @Mark='Start'] and following-sibling::ukl:P/descendant::*[@ChangeId='" +  changeId + "' and @Mark='End']))]");
		SetNodePITVersion("//ukl:Tabular[not(@Status='Prospective') and not(ancestor::ukl:BlockAmendment) and not(ancestor::ukl:P1group) and not(ancestor::ukl:P1) and not(ancestor::ukl:*/@Status='Prospective') and (descendant::*[@ChangeId='" + changeId + "'] or (preceding-sibling::ukl:Tabular/descendant::*[@ChangeId='" +  changeId + "' and @Mark='Start'] and following-sibling::ukl:Tabular/descendant::*[@ChangeId='" +  changeId + "' and @Mark='End']))]");
		SetNodePITVersion("//ukl:SignedSection[not(@Status='Prospective') and not(ancestor::ukl:BlockAmendment) and (child::*/*[@ChangeId='" +  changeId + "']  or descendant::*[@ChangeId='" +  changeId + "'])]");
		
	}
	
	//Set the PIT version for non-textual amendments
	function SetPITVersionForNonTextualAmendments(changeId)
	{
		//Find node where PIT version is set - either P1group, P1, Tabular or in rare cases Part, Schedule, Chapter or Prelims
		SetNodePITVersion("//ukl:PrimaryPrelims[not(@Status='Prospective') and not(ancestor::ukl:BlockAmendment) and descendant::ukl:CommentaryRef[@Ref='" +  changeId + "']]");
		SetNodePITVersion("//ukl:EUPrelims[not(@Status='Prospective') and not(ancestor::ukl:BlockAmendment) and descendant::ukl:CommentaryRef[@Ref='" +  changeId + "']]");
		SetNodePITVersion("//ukl:SecondaryPrelims[not(@Status='Prospective') and not(ancestor::ukl:BlockAmendment) and descendant::ukl:CommentaryRef[@Ref='" +  changeId + "']]");
		SetNodePITVersion("//ukl:Part[not(@Status='Prospective') and not(ancestor::ukl:BlockAmendment) and child::*/ukl:CommentaryRef[@Ref='" +  changeId + "']]");
		SetNodePITVersion("//ukl:EUPart[not(@Status='Prospective') and not(ancestor::ukl:BlockAmendment) and child::*/ukl:CommentaryRef[@Ref='" +  changeId + "']]");
		SetNodePITVersion("//ukl:EUTitle[not(@Status='Prospective') and not(ancestor::ukl:BlockAmendment) and child::*/ukl:CommentaryRef[@Ref='" +  changeId + "']]");
		SetNodePITVersion("//ukl:Schedule[not(@Status='Prospective') and not(ancestor::ukl:BlockAmendment) and child::*/*/ukl:CommentaryRef[@Ref='" +  changeId + "']]");
		SetNodePITVersion("//ukl:Chapter[not(@Status='Prospective') and not(ancestor::ukl:BlockAmendment) and child::*/ukl:CommentaryRef[@Ref='" +  changeId + "']]");
		SetNodePITVersion("//ukl:EUChapter[not(@Status='Prospective') and not(ancestor::ukl:BlockAmendment) and child::*/ukl:CommentaryRef[@Ref='" +  changeId + "']]");
		SetNodePITVersion("//ukl:EUSection[not(@Status='Prospective') and not(ancestor::ukl:BlockAmendment) and child::*/ukl:CommentaryRef[@Ref='" +  changeId + "']]");
		SetNodePITVersion("//ukl:EUSubsection[not(@Status='Prospective') and not(ancestor::ukl:BlockAmendment) and child::*/ukl:CommentaryRef[@Ref='" +  changeId + "']]");
		SetNodePITVersion("//ukl:Division[not(@Status='Prospective') and not(ancestor::ukl:BlockAmendment) and child::*/ukl:CommentaryRef[@Ref='" +  changeId + "']]");
		SetNodePITVersion("//ukl:Pblock[not(@Status='Prospective') and not(ancestor::ukl:BlockAmendment) and child::*/ukl:CommentaryRef[@Ref='" +  changeId + "']]");
		SetNodePITVersion("//ukl:P1group[not(@Status='Prospective') and not(ancestor::ukl:BlockAmendment) and descendant::ukl:CommentaryRef[@Ref='" +  changeId + "']]");
		SetNodePITVersion("//ukl:P1[not(@Status='Prospective') and not(ancestor::ukl:BlockAmendment) and not(parent::ukl:P1group) and descendant::ukl:CommentaryRef[@Ref='" +  changeId + "']]");
		SetNodePITVersion("//ukl:Tabular[not(@Status='Prospective') and not(ancestor::ukl:BlockAmendment) and not(ancestor::ukl:P1group) and not(ancestor::ukl:P1) and not(ancestor::ukl:*/@Status='Prospective') and descendant::ukl:CommentaryRef[@Ref='" +  changeId + "']]");
		SetNodePITVersion("//ukl:SignedSection[not(@Status='Prospective') and not(ancestor::ukl:BlockAmendment) and descendant::ukl:CommentaryRef[@Ref='" +  changeId + "']]");
		
	}
	
	//Set the PIT version on the appropriate node
	function SetNodePITVersion(nodeXPath)
	{
		var nodesList;
		var startDateAttXPath = (nodeXPath + "/@RestrictStartDate")
		var nodeWithMatchAttXPath = (nodeXPath + "[not(@Match='false')]")
		
		//If current task is a review then compare existing RestrictStartDate in doc with task PIT
		if (/\/review\//.test(GetSourceUri())) 
		{
			var startDateAtt = ActiveDocument.getNodesByXPath(startDateAttXPath);
			
			if (startDateAtt != null &&  startDateAtt.Length > 0) 
			{
				var startDateValue = startDateAtt.item(0).nodeValue;
				if (startDateValue > GetPITVersion())
				{
					nodesList = ActiveDocument.getNodesByXPath(nodeWithMatchAttXPath);
				}
				else
				{
					nodesList = ActiveDocument.getNodesByXPath(nodeXPath);
				}
			}
		}
		else
		{
			nodesList = ActiveDocument.getNodesByXPath(nodeXPath);
		}
			
		if (nodesList != null &&  nodesList.Length > 0) 
		{
			for (var i =0;i<nodesList.length;i++) 
			{
				Selection.SelectNodeContents(nodesList.item(i));
				var containerInnerName = Selection.ContainerName;
				containerInnerName = containerInnerName.replace("leg:", "");
				Selection.ElementAttributeNS("", "RestrictStartDate", "http://www.legislation.gov.uk/namespaces/legislation", containerInnerName, 0) = GetPITVersion();
			}
		}
	}
	
	//Selected commentary ID
	function GetSelectedCommentaryId()
	{
		var taskCtrl = ResourceManager.ControlInTab("Tasks");
		if (taskCtrl == null)	
			Application.Alert("The task control is not installed");
		else 
		{
			var selectedCommentaryId = taskCtrl.SelectedCommentaryId;
			if (selectedCommentaryId == "") 
			{
				Application.Alert("Unable to find the commentary in the task tree.");
			}
			else 
			{	
				return selectedCommentaryId;
			}
		}
		
		return "";
	}	
	
	// To insert Addition/Substitution tag. We have start and end range. So no need to calculate
	function InsertTagEx(startRange, endRange, tagName, commentaryId, changeId, changeType, extent)
	{
		//Start range insert
		startRange.Select();
		while(!Selection.CanInsertNS("http://www.legislation.gov.uk/namespaces/legislation", tagName))
			Selection.MoveRight(); 
		// Inserting the start tag 	
		//For textual amendments make sure there is a space before
				
		if((changeType == 'InlineAddition' || changeType == 'TextualAmendment') && Selection.CanInsertText)
				Selection.PasteStringAsText(" ");
		Selection.FindInsertLocationNS ("http://www.legislation.gov.uk/namespaces/legislation",tagName, true);
		Selection.InsertWithTemplateNS ("http://www.legislation.gov.uk/namespaces/legislation", tagName);
		Selection.ElementAttributeNS("", "ChangeId", "http://www.legislation.gov.uk/namespaces/legislation", tagName, 0) = changeId;
		Selection.ElementAttributeNS("", "CommentaryRef", "http://www.legislation.gov.uk/namespaces/legislation", tagName, 0) = commentaryId;
		Selection.ElementAttributeNS("", "Mark", "http://www.legislation.gov.uk/namespaces/legislation", tagName, 0) = "Start";
		
		if(extent != null && extent != '')
			Selection.ElementAttributeNS("", "Extent", "http://www.legislation.gov.uk/namespaces/legislation", tagName, 0) =  extent;		
		
		//End range insert
		endRange.Select();
		while(!Selection.CanInsertNS("http://www.legislation.gov.uk/namespaces/legislation", tagName))
			Selection.MoveLeft(); 
			
		// Inserting the end tag 
		Selection.InsertWithTemplateNS ("http://www.legislation.gov.uk/namespaces/legislation", tagName);
		Selection.ElementAttributeNS("", "ChangeId", "http://www.legislation.gov.uk/namespaces/legislation", tagName, 0) = changeId;
		Selection.ElementAttributeNS("", "CommentaryRef", "http://www.legislation.gov.uk/namespaces/legislation", tagName, 0) = commentaryId;
		Selection.ElementAttributeNS("", "Mark", "http://www.legislation.gov.uk/namespaces/legislation", tagName, 0) = "End";
		//For textual amendments make sure there is a space after
		if((changeType == 'InlineAddition' || changeType == 'TextualAmendment') && Selection.CanInsertText) {
			Selection.MoveRight(); 
			Selection.PasteStringAsText(" ");
		}
	}
	
	//This is used by Repeal
	function InsertTag(tagName, commentaryId, changeId, substitutionRef, extent, retainText)
	{
		// Creating a copy range of the current selection
		var repealedRange = Selection.Duplicate;
		Selection.MoveLeft();
		
		// Inserting the start tag 	
		Selection.FindInsertLocationNS ("http://www.legislation.gov.uk/namespaces/legislation",tagName, true);
		Selection.InsertWithTemplateNS ("http://www.legislation.gov.uk/namespaces/legislation", tagName);
		Selection.ElementAttributeNS("", "ChangeId", "http://www.legislation.gov.uk/namespaces/legislation", tagName, 0) = changeId;
		if (commentaryId != null && commentaryId != '')
		{
			Selection.ElementAttributeNS("", "CommentaryRef", "http://www.legislation.gov.uk/namespaces/legislation", tagName, 0) = commentaryId;
		}
		Selection.ElementAttributeNS("", "Mark", "http://www.legislation.gov.uk/namespaces/legislation", tagName, 0) = "Start";
		
		if (tagName == "Repeal" && retainText==false)
			Selection.ElementAttributeNS("", "RetainText", "http://www.legislation.gov.uk/namespaces/legislation", tagName, 0) = "false";
		else if (tagName == "Repeal" && retainText==true)
			Selection.ElementAttributeNS("", "RetainText", "http://www.legislation.gov.uk/namespaces/legislation", tagName, 0) = "true";
		
		if (substitutionRef != null && substitutionRef != '')
		{
			Selection.ElementAttributeNS("", "SubstitutionRef", "http://www.legislation.gov.uk/namespaces/legislation", tagName, 0) = substitutionRef;		
		}
		if(extent != null && extent != '')
		{
			Selection.ElementAttributeNS("", "Extent", "http://www.legislation.gov.uk/namespaces/legislation", tagName, 0) =  extent;		
		}

		// Moving it to the position where the end tag should be added 
		repealedRange.Select();
		Selection.MoveRight();
		while(!Selection.CanInsertNS("http://www.legislation.gov.uk/namespaces/legislation", tagName))
			Selection.MoveLeft(); 
			
		// Inserting the end tag 
		Selection.InsertWithTemplateNS ("http://www.legislation.gov.uk/namespaces/legislation", tagName);
		Selection.ElementAttributeNS("", "ChangeId", "http://www.legislation.gov.uk/namespaces/legislation", tagName, 0) = changeId;
		if (commentaryId != null && commentaryId != '')
		{
			Selection.ElementAttributeNS("", "CommentaryRef", "http://www.legislation.gov.uk/namespaces/legislation", tagName, 0) = commentaryId;
		}
		Selection.ElementAttributeNS("", "Mark", "http://www.legislation.gov.uk/namespaces/legislation", tagName, 0) = "End";
		
		if (substitutionRef != null && substitutionRef != '')
		{
			Selection.ElementAttributeNS("", "SubstitutionRef", "http://www.legislation.gov.uk/namespaces/legislation", tagName, 0) = substitutionRef;		
		}
	}	

	//Insert the repeal tag
	function InsertRepeal(commentaryId, changeId, substitutionRef, extent, retainText, amendmentNode)
	{
		InsertTag("Repeal", commentaryId, changeId,substitutionRef, extent, retainText);
		
		var changeType = amendmentNode;
		
		// change on 13/11/2014 (Mark Jones) to make sure for textual amendment RestrictStartDate is added to P1 or P1group 
		// example task-update-step-ukpga-2010-28-schedule-2-2013-04-01-high-level-amends
		switch(changeType) 
		{
			case "BlockRepeal":
			case "InlineRepeal":
			case "BlockSubstitution":
			case "InlineSubstitution":
			case "TextualAmendment":
				SetPITVersionForTextualAmendments(changeId, changeType);
				break; 
			default:
				break;
		}
	}			

	//Removing block container..
	function RemoveBlockContainer() 
	{
		var containerRange = Selection.Duplicate;
		for (index=0;index<containerRange.count;index++) 
		{
			var node = containerRange.NodeItem(index);
			if (node.nodeName == 'BlockAmendment')
			{
				Selection.SelectNodeContents(node);
				if (Selection.CanRemoveContainerTags)
				{
					Selection.RemoveContainerTags();
				}
			}
		}
	}
	
	function ContainsAmendments(node, found) 
	{
		// If this is a DOMElement node, do "enter
		// element" processing
		Application.alert(node.nodeType);
		if (node.nodeType==1) {Application.alert(node.nodeName);
			var localname = node.nodeName.replace("leg:", "");
			if (localname == 'Addition' || localname == 'Repeal' || localname == 'Substitution') {
				found = "true";Application.alert(found);
				return "true";
			}
			else {
				if (node.hasChildNodes()) {Application.alert("next child");
					ContainsAmendments(node.firstChild, found);
				}
				// Continue with this node's siblings
				if (node.nextSibling!=null) {Application.alert("next sibling");
					ContainsAmendments(node.nextSibling, found);
				}
			}
		}

		// Do if this is a DOMText node
		if (node.nodeType==3) {Application.alert(node.nodeValue);
			// Continue with this node's siblings
			if (found == 'true') {
				Application.alert(found);
				return "true";
			}
			else if  (node.nextSibling!=null) {Application.alert("next text sibling");
			ContainsAmendments(node.nextSibling, found);
			}
		}
		
		
	}
	
	function InsertAddition(amendmentNode, commentaryId, changeId, extent)
	{
		InsertAdditionorSubstitution(amendmentNode, commentaryId, changeId, extent, "", "Addition");
	}
	
	function InsertSubstitution(amendmentNode, commentaryId, changeId, extent, existingCrossHeadId)
	{
		InsertAdditionorSubstitution(amendmentNode, commentaryId, changeId, extent, existingCrossHeadId, "Substitution");
	}
	
	function InsertAdditionorSubstitution(amendmentNode, commentaryId, changeId, extent, existingCrossHeadId, tagName)
	{
		// Creating a copy range of the current selection
		var insertStartRange = Selection.Duplicate;
		// pasting the new text
		InsertNewContent(existingCrossHeadId);
		// getting the amendment type
		var changeType = GetAmendmentType(amendmentNode) 
		
		switch(changeType) 
		{
			case "BlockAddition":
			case "BlockSubstitution":
				Selection.MoveRight(); // selecting the original block
				break;
			case "InlineAddition":
			case "InlineSubstitution":
			case "TextualAmendment":
				break;
		}
		// selecting the new text
		var insertEndRange = Selection.Duplicate;		
		insertStartRange.Select();
		Selection.ExtendTo(insertEndRange);
		
		// change on 12/11/2014 (Mark Jones / Faiz) to allow to Addition and Substitution 
		// adding attribute for Block Addition
		switch(changeType) 
		{
			case "BlockAddition":
			case "BlockSubstitution":
				SetPITVersionInCurrentSelection();
				break;		
			default:
				break;
		}

		// reselecting the original
		insertStartRange.Select();
		Selection.ExtendTo(insertEndRange);		
		//Insert the tag
		InsertTagEx(insertStartRange, insertEndRange, tagName, commentaryId, changeId, changeType, extent);
		
		// change on 12/11/2014 (Mark Jones / Faiz) to make sure for textual amendment RestrictStartDate is added to P1  or  P1group 
		// example task-update-step-mwa-2009-5-act-2010-05-05-high-level-amends(7)
		switch(changeType) 
		{
			case "BlockAddition":
			case "BlockSubstitution":
			case "InlineAddition":
			case "InlineSubstitution":					
			case "TextualAmendment":									
				SetPITVersionForTextualAmendments(changeId, changeType);				
				break; 
			default:					
				break;
		}
		
	}	
	
	//Inserting  commentary node.
	function InsertCommentary(commentaryId) 
	{	
		// now adding the commentaries
		var effectCommentariesNodeList = ActiveDocument.getNodesByXPath("//ukl:Effect/ukl:Commentary[@id='" + commentaryId +  "']");
		if (effectCommentariesNodeList == null || effectCommentariesNodeList.Length==0) 
		{ // no commentary found, ignore

		}
		else 
		{ // 
			var effectCommentaryNode = effectCommentariesNodeList.item(0);
			var commentariesNodeList = ActiveDocument.getNodesByXPath("//ukl:Commentaries");		
			var commentariesAdded=false;
			if (commentariesNodeList == null || commentariesNodeList.Length==0) 
			{ // no commentaries found, inserting the commentaries node
				Selection.FindInsertLocationNS ("http://www.legislation.gov.uk/namespaces/legislation","Commentaries", true);
				Selection.InsertWithTemplateNS("http://www.legislation.gov.uk/namespaces/legislation", "Commentaries")
				commentariesAdded = true;
			}
			
			commentariesNodeList = ActiveDocument.getNodesByXPath("//ukl:Commentaries");		
			var existsCommentariesNodeList = 
				ActiveDocument.getNodesByXPath("//ukl:Commentaries[ukl:Commentary[@id='" +  commentaryId + "']]");
			if (existsCommentariesNodeList != null &&  existsCommentariesNodeList.Length>0) 
			{ // commentary already exists, so no need to add again, ignore
				
			}
			else 
			{ // adding commentary
				Selection.SelectNodeContents(effectCommentaryNode);
				Selection.SelectElement();
				var commentaryText  = Selection.Duplicate.Text;
				var commentariesNode = commentariesNodeList.item(0);
				Selection.SelectNodeContents(commentariesNode);
				Selection.MoveRight();
				if (commentariesAdded)
					Selection.MoveLeft();
				if 	(effectCommentaryNode != null)
				{
					Selection.PasteString(commentaryText);
				}
			}

		}
	}

	// Insert E note annotations for limited extent substitutions
	function InsertExtentCommentary(commentaryId, newExtent, existingExtent) 
	{	
		var remainingExtentCommentaryNode = '<ukl:Commentary xmlns:ukl="http://www.legislation.gov.uk/namespaces/legislation" id="' + commentaryId + '1" Type="E"><ukl:Para><ukl:Text>This version of this provision extends to ' + existingExtent + ' only. A new version of this provision has been created for ' + newExtent + '</ukl:Text></ukl:Para></ukl:Commentary>';
		var newExtentCommentaryNode = '<ukl:Commentary xmlns:ukl="http://www.legislation.gov.uk/namespaces/legislation" id="' + commentaryId + '2" Type="E"><ukl:Para><ukl:Text>This version of this provision extends to ' + newExtent + ' only. The original version of this provision exists for ' + existingExtent + '</ukl:Text></ukl:Para></ukl:Commentary>';
		var commentariesNodeList = ActiveDocument.getNodesByXPath("//ukl:Commentaries");		
		var commentariesAdded=false;
		if (commentariesNodeList == null || commentariesNodeList.Length == 0) 
		{ // no commentaries found, inserting the commentaries node
			Selection.FindInsertLocationNS ("http://www.legislation.gov.uk/namespaces/legislation","Commentaries", true);
			Selection.InsertWithTemplateNS("http://www.legislation.gov.uk/namespaces/legislation", "Commentaries")
			commentariesAdded = true;
		}
			
		var existsRemainingExtentCommentaryNodeList = ActiveDocument.getNodesByXPath("//ukl:Commentaries[ukl:Commentary[@id='" +  commentaryId + "1']]");
		var existsNewExtentCommentaryNodeList = ActiveDocument.getNodesByXPath("//ukl:Commentaries[ukl:Commentary[@id='" +  commentaryId + "2']]");
		if (existsRemainingExtentCommentaryNodeList != null &&  existsRemainingExtentCommentaryNodeList.Length > 0) 
		{ // commentary already exists, so no need to add again, ignore
			
		}
		else if (existsNewExtentCommentaryNodeList != null &&  existsNewExtentCommentaryNodeList.Length > 0) 
		{ // commentary already exists, so no need to add again, ignore
			
		}
		else 
		{ // adding commentary
			var commentariesNode = commentariesNodeList.item(0);
			Selection.SelectNodeContents(commentariesNode);
			Selection.MoveRight();
			if (commentariesAdded)
			{
				Selection.MoveLeft();
			}
			Selection.PasteString(remainingExtentCommentaryNode);
			Selection.PasteString(newExtentCommentaryNode);
			InsertExtentCommentaryRef(commentaryId, 'Repeal');
			InsertExtentCommentaryRef(commentaryId, 'Addition');
		}
	}
	
	// Insert E note annotations references for limited extent substitutions
	function InsertExtentCommentaryRef(commentaryId, nodeType)
	{
		var extentCommentaryId;
		if  (nodeType == 'Repeal')
			extentCommentaryId = commentaryId + '1';
		else
			extentCommentaryId = commentaryId + '2';
		
		var extentCommentaryRefNode = '<ukl:CommentaryRef xmlns:ukl="http://www.legislation.gov.uk/namespaces/legislation" Ref="' + extentCommentaryId + '"/>';
		var initialNodesList = ActiveDocument.getNodesByXPath("//ukl:*/ukl:Title//ukl:" + nodeType + "[@CommentaryRef='" + commentaryId + "'] | //ukl:*/ukl:Number//ukl:" + nodeType + "[@CommentaryRef='" + commentaryId + "']");

		if (initialNodesList != null &&  initialNodesList.Length > 0)
		{
			for (var i = 0; i < initialNodesList.length; i++)
			{
				var node = initialNodesList.item(i);
				Selection.SelectNodeContents(node);
				Selection.MoveLeft();
				Selection.PasteString(extentCommentaryRefNode);
			}
		}
		
		var nodesList = ActiveDocument.getNodesByXPath("//ukl:*[(.//ukl:Text//ukl:" + nodeType + "/@CommentaryRef='" + commentaryId + "' and (preceding-sibling::ukl:*/ukl:Title//ukl:" + nodeType + "/@CommentaryRef='" +  commentaryId + "' or preceding-sibling::ukl:*/ukl:Number//ukl:" + nodeType + "/@CommentaryRef='" +  commentaryId + "')) or ((preceding-sibling::ukl:*/ukl:Title//ukl:" + nodeType + "/@CommentaryRef='" + commentaryId + "' or preceding-sibling::ukl:*/ukl:Number//ukl:" + nodeType + "/@CommentaryRef='" + commentaryId + "') and following-sibling::ukl:*//ukl:Text//ukl:" + nodeType + "/@CommentaryRef='" + commentaryId + "')]/ukl:Title");
		
		if (nodesList != null &&  nodesList.Length > 0)
		{
			for (var i = 0; i < nodesList.length; i++)
			{
				var node = nodesList.item(i);
				Selection.SelectNodeContents(node);
				Selection.MoveRight();
				Selection.PasteString(extentCommentaryRefNode);
			}
		}
	}
	
	// Inserting new content into document as an amendment
	function InsertNewContent(existingCrossHeadId)
	{
		// removing <ukl:BlockAmendment> wrapper from new text (if present)
		var clipBoardText = Application.Clipboard.Text;
		if (/^<[^:]*:BlockAmendment[^>]*>/.test(clipBoardText))
		{
			clipBoardText = clipBoardText.replace(/^<[^:]*:BlockAmendment[^>]*>|<\/[^:]*:BlockAmendment>$/g, "");
			clipBoardText = clipBoardText.replace(/<(ukl:[^> ]*)/g, '<$1 xmlns:ukl="http://www.legislation.gov.uk/namespaces/legislation"');
		}
		if (/^\s*<[^:]*:Pblock[^>]*>/.test(clipBoardText) && existingCrossHeadId != null && existingCrossHeadId != '')
		{
			clipBoardText = clipBoardText.replace(/^\s*<([^:]*:Pblock[^>]*)/, '<$1 id="' + existingCrossHeadId + '"');
		}
		
		// pasting the new content
		Selection.PasteString(clipBoardText);
	}
	
	// Work out extent for substituted sections
	function GetSectionExtent(newExtent, existingExtent)
	{
		var newExtentValues = newExtent.split("+");
		var existingExtentValues = existingExtent;
		
		if (existingExtentValues == "")
		{
			existingExtentValues = ["E", "W", "S", "N.I."];
		}
		else
		{
			existingExtentValues = existingExtentValues.split("+");
		}
		
		var remainingExtentValues = ArrDiff(existingExtentValues, newExtentValues); 
		
		return remainingExtentValues.join("+");
	}
	
	// Output difference between two arrays
	function ArrDiff(a1, a2)
	{
		var a=[], diff=[];
		for(var i=0;i<a1.length;i++)
			a[a1[i]]=true;
		for(var i=0;i<a2.length;i++)
			if(a[a2[i]]) delete a[a2[i]];
			else a[a2[i]]=true;
		for(var k in a)
			diff.push(k);
		return diff;
	}
	
	//Getting amendment URI.
	function GetAmendmentNode(amendmentURI) 
	{	
		// getting the amendment node by amendmentURI
		var amendmentNodeList = ActiveDocument.getNodesByXPath("//ukl:Effect/ukl:Amendment[@URI='" + amendmentURI +  "']");
		if (amendmentNodeList == null || amendmentNodeList.Length==0) 
		{ // no amendment found, ignore
			return null;
		}
		else 
		{ // 
			var amendmentNode = amendmentNodeList.item(0);
			return amendmentNode;
		}
	}

	//Getting limited extent value.
	function GetLimitedExtent(amendmentURI) 
	{
		// getting the limited extent value by amendmentURI
		var limitedExtent = ActiveDocument.getNodesByXPath("//ukl:Effect[ukl:Amendment/@URI='" + amendmentURI +  "']/@RestrictExtent");
		
		if (limitedExtent == null || limitedExtent.Length == 0) 
		{ 
			// no limited extent found, ignore
			return null;
		}
		else
		{ 
			// limited extent exists
			var limitedExtentAttValue = limitedExtent.item(0);
			
			if (limitedExtentAttValue.childNodes.length > 0)  
				// getting the text node
				limitedExtentValue = limitedExtentAttValue.childNodes.item(0).nodeValue;	
				return limitedExtentValue;
		}
	}
	
	//Getting amendemnt type.
	function GetAmendmentType(amendmentNode) 
	{	
		if (amendmentNode != null) 
		{
			return amendmentNode.attributes.getNamedItem("ChangeType").nodeValue;		
		}
		
		return ""; 
	}

	//Getting amendemnt status.
	function GetAmendmentStatus(amendmentNode) 
	{	
		if (amendmentNode != null) 
		{
			return amendmentNode.attributes.getNamedItem("Status").nodeValue;		
		}
		
		return ""; 
	}	
	
	//Complete the amendment
	function CompleteAmendment(amendmentNode, changeId) 
	{	
		if (amendmentNode != null) 
		{
			amendmentNode.attributes.getNamedItem("Status").nodeValue = "Complete";
			var changeIdNode = amendmentNode.attributes.getNamedItem("ChangeId");
			if( changeIdNode == null)
			{	
				var changeIDAttr = ActiveDocument.CreateAttribute("ChangeId");
				amendmentNode.attributes.setNamedItem(changeIDAttr);
			}
			amendmentNode.attributes.getNamedItem("ChangeId").nodeValue = changeId;		
			
		}
	}		
	
	//Get the next ID based on current ID
	function GetNextChangeId(commentaryId)
	{
		var currentTime = new Date().getTime();
		var changeId = commentaryId + "-" + (currentTime);
		return changeId;
	}
	
	//Get the next change ID based on current ID
	function GetChangeId(commentaryId,nextChangeId)
	{
		var currentTime = new Date().getTime();
		var changeId = commentaryId + "-" + (currentTime + 1);
		return changeId;
	}
	
	//Load the task list
	function LoadTaskList() 
	{	
		var fileName= new String(ActiveDocument.name);
		if (fileName.indexOf("task-")==0)
		{
			var taskCtrl;
			try 
			{
				taskCtrl = ResourceManager.ControlInTab("Tasks");
			}
			catch (e) {		
				// failed to load the tasks 
			}	

			if (taskCtrl != null && taskCtrl.Task != ActiveDocument.Fullname) {
					taskCtrl.Task =  ActiveDocument.Fullname;
			}
		}	
	}
	
	//Inserting commentary refs
	function InsertCommentaryRef(commentaryId) 
	{	
		var tagName = "CommentaryRef";
		Selection.FindInsertLocationNS ("http://www.legislation.gov.uk/namespaces/legislation",tagName, true);
		Selection.InsertWithTemplateNS("http://www.legislation.gov.uk/namespaces/legislation", tagName);
		Selection.ElementAttributeNS("", "Ref", "http://www.legislation.gov.uk/namespaces/legislation", tagName, 0) = commentaryId;
	}
	
	// Amendment changeid
	function GetAmendmentChangeId(amendmentNode) 
	{
		if (amendmentNode != null) 
		{
			return amendmentNode.attributes.getNamedItem("ChangeId").nodeValue;		
		}
		return ""; 
	}
	
	
	function UpdateTaskAmendment(amendmentNode) 
	{
		if (amendmentNode != null) 
		{
			amendmentNode.attributes.getNamedItem("Status").nodeValue = "ToDo";
			amendmentNode.attributes.getNamedItem("ChangeId").nodeValue = "";
		}
	}
	
	function IsAmendmentComplete(amendmentNode) 
	{	
		if (amendmentNode != null) 
		{
			var status = amendmentNode.attributes.getNamedItem("Status").nodeValue
			//if( status == "Complete" || status == "Check"))
				return true;
		}
		return false; 
	}
	
	function GetNodeByAttributeId(name, id, mark)
	{
		var path = "//node()[@" + name + "='" + id + "' and @Mark='" + mark +"']";
		var nodeList = ActiveDocument.getNodesByXPath(path);		
		if(nodeList != null && nodeList.Length == 1)
			return nodeList.item(0);
		else
			return null;
	}
	
	function DeleteNode(node)
	{
		Selection.SelectNodeContents(node);
        Selection.MoveLeft(XMetaL.SQMovementType.sqExtend);
        Selection.Delete();
	}
	
	function RemoveCommentary(commentaryID, changeType)
	{
		var commentaryRefs = null;
		if(changeType == "NonTextualAmendment")
			commentaryRefs = ActiveDocument.getNodesByXPath("//node()[@Ref='" + commentaryID + "']");		
		else
			commentaryRefs = ActiveDocument.getNodesByXPath("//node()[@CommentaryRef='" + commentaryID + "']");		

		if(commentaryRefs != null && commentaryRefs.Length == 0)
		{
			var  commentaryNodeList = ActiveDocument.getNodesByXPath("//ukl:Commentaries/ukl:Commentary[@id='" + commentaryID +  "']");
			if(commentaryNodeList.Length == 1)
			{
				DeleteNode(commentaryNodeList.item(0));
				return true;
			}
		}
		return false;
	}
	
	function SelectChange(changeId, changeType)
	{
		var startNode = GetNodeByAttributeId("ChangeId", changeId, "Start");
		var endNode = GetNodeByAttributeId("ChangeId", changeId, "End");
		if(startNode != null && endNode != null)
		{
			Selection.SelectNodeContents(endNode);		
			var endRange = Selection.Duplicate;
			
			Selection.SelectNodeContents(startNode);		
			var startRange = Selection.Duplicate;

			var range = startRange
			while (true)
            {
				Selection.MoveRight(SQMovementType.sqExtend);
				 if (range == Selection)
					break;
					
				range = Selection.Duplicate;	
				if (Selection.Text == "")
					continue;
				
				if (Selection.Contains(startRange,true) && Selection.Contains(endRange,true))
					break; 
			}
			var selectedNodeCount = Selection.Duplicate.count;
			var nodeCount = 0;
            var containerNode = Selection.ContainerNode;
			for (var i = 0; i < containerNode.childNodes.length; i++)
			{
				var containerChildNode = containerNode.childNodes.item(i);
				if (containerChildNode.nodeType == 1)
					nodeCount++;
			}
			if (nodeCount == selectedNodeCount)
			{
				switch(changeType) 
				{
					case "BlockAddition":
					case "BlockRepeal":
					case "BlockSubstitution":
						Selection.MoveRight(XMetaL.SQMovementType.sqExtend);
						break;
					case "InlineAddition":
					case "InlineRepeal":
					case "InlineSubstitution":
					case "TextualAmendment":
					case "NonTextualAmendment":
						break;						
				}
			}
		}
	}
	
	function checkforupdates(containerRange) {
		for (index=0;index<containerRange.count;index++) 
		{	
			var node = containerRange.NodeItem(index);
			var updates = node.getNodesByXPath("descendant-or-self::*[self::ukl:Repeal or self::ukl:Addition or self::ukl:Substitution][@Mark = 'End']");
			if ((updates != null &&  updates.Length > 0) ) {
				Application.Alert("has updates");return "updates";
			}
		}
		
	}
	
	
	
	function PerformSubstitution(retainText) 
	{
		if (Selection.Text == "") 
			Application.Alert("No text has been selected for substitution");
		else 
		{
			if (!Application.Clipboard.HasText)
				Application.Alert("No text has been copied from the source document for substitution");      	
			else 
			{
				var selectedAmendmentUri = GetSelectedAmendmentUri();
				if (selectedAmendmentUri != "") 
				{
					var selectedCommentaryId = GetSelectedCommentaryId();
					if (selectedCommentaryId != "") 
					{
						var changeIdRepeal = GetNextChangeId(selectedCommentaryId);								
						var changeIdAddition = GetChangeId(selectedCommentaryId,1);													
						var amendmentNode  = GetAmendmentNode(selectedAmendmentUri);
						
						// getting the amendment type
						var changetype = GetAmendmentType(amendmentNode);
						
						// check whether amendment is a substitution
						if (changetype == "InlineSubstitution" || changetype == "BlockSubstitution" || changetype == "TextualAmendment")
						{
							// check whether amendment has limited extent
							var limitedExtent = GetLimitedExtent(selectedAmendmentUri);
							var cancelRequest = "";
							if (limitedExtent != null)
							{
								cancelRequest = Application.prompt("This amendment has limited extent; there is a 'Limited Extent Substitution' option in the menu for substitutions with limited extent. Would you like to cancel this command? [y|n}", "y"); 
							}
							else
							{
								cancelRequest = 'n'
							}
							
							var containerRange = Selection.Duplicate;
							var check = checkforupdates(containerRange);
							
							if (check != null && check.match(/update/g)) {
								var dlgMsg = "This selection contains existing updates. Do you want to continue";
								var dlgTitle = "WARNING";
								var canContinue = Application.Confirm(dlgMsg,dlgTitle);
							} else {var canContinue = true;}
						
							if (cancelRequest == 'n' && canContinue)
							{
								// saving the current selection
								var substitutionRange = Selection.Duplicate;
								
								if (retainText) 
								{
									// inserting repeal
									InsertRepeal(selectedCommentaryId, changeIdRepeal,changeIdAddition, "", true, amendmentNode);
									
									substitutionRange.Select();
									
									// move right
									Selection.MoveRight();
									
									if (changetype == "InlineSubstitution" || changetype == "TextualAmendment")
									{
										Selection.MoveRight();
										Selection.MoveRight();
									}
									
									// inserting addition
									InsertAddition(amendmentNode, selectedCommentaryId, changeIdAddition, "");
								}
								else 
								{
									var currentSelection = Selection.Text;
									var existingCrossHeadId;
									if (/^<[^:]*:?Pblock[^>]*>/.test(currentSelection))
									{
										var getId = currentSelection.match(/^<[^:]*:?Pblock[^>]*id="([^"]*)"/);
										existingCrossHeadId = getId[1];
									}
									
									// delete the selection
									Selection.Delete();
									// inserting substitution
									InsertSubstitution(amendmentNode, selectedCommentaryId, changeIdAddition, "", existingCrossHeadId);
								}
								// inserting commentary
								InsertCommentary(selectedCommentaryId);
								// completing the amendment
								CompleteAmendment(amendmentNode, changeIdAddition);					
								// clearing the clipboard and saving the document
								Application.Clipboard.SetEmpty();
								ActiveDocument.Save();
							}
						}
						else
						{
							Application.Alert("Current task selected is not a substitution task");
						}
					}
				}
			}
		}		
	}
	
	function UndoRepeal(changeId)
	{
		var undoneCount = 0;
		var startNode = GetNodeByAttributeId("ChangeId", changeId, "Start");
		var endNode = GetNodeByAttributeId("ChangeId", changeId, "End");
		if(startNode != null && endNode != null)
		{
			DeleteNode(startNode);
			++undoneCount;
			DeleteNode(endNode);
			++undoneCount;
		}
		return undoneCount;
	}
	
	function UndoAddition(changeId, changeType)
	{
		var undoneCount = 0;
		var startNode = GetNodeByAttributeId("ChangeId", changeId, "Start");
		var endNode = GetNodeByAttributeId("ChangeId", changeId, "End");
		if(startNode != null && endNode != null)
		{
			SelectChange(changeId, changeType);
			Selection.Delete();
			++undoneCount;
		}
		return undoneCount;
	}
	
	function UndoSubstitution(changeId, changeType)
	{
		var undoneCount = 0;
		var startRepealTag = GetNodeByAttributeId("SubstitutionRef", changeId, "Start");
		var endRepealTag = GetNodeByAttributeId("SubstitutionRef", changeId, "End");
		if(startRepealTag != null  && endRepealTag!= null)
		{
			undoneCount = UndoAddition(changeId, changeType);
			if(undoneCount > 0)
			{
				// delete the startRepealTag & the endRepealTag
				DeleteNode(startRepealTag);
				++undoneCount;
				DeleteNode(endRepealTag);
				++undoneCount;
			}
		}
		return undoneCount;
	}
	
	function GetTextualAmendmentType(changeId)
	{
		var startTag = GetNodeByAttributeId("ChangeId", changeId, "Start");
		if(startTag.nodeName == "Repeal")
			return "InlineRepeal";
		else
		{
			var startRepealTag = GetNodeByAttributeId("SubstitutionRef", changeId, "Start");
			if(startRepealTag != null)
				return "InlineSubstitution";
			else
				return "InlineAddition";
		}		
	}
	
	function UndoCommentaryRef(selectedCommentaryId)
	{
		var undoneCount = 0;
		var commentaryRefs = ActiveDocument.getNodesByXPath("//ukl:CommentaryRef[@Ref='" + selectedCommentaryId + "']");		
		if(commentaryRefs != null && commentaryRefs.Length == 1)
		{
			DeleteNode(commentaryRefs.item(0));
			++undoneCount;
		}
		return undoneCount;
	}
	
	function UndoAmendment(selectedCommentaryId, amendmentNode )
	{
		var undoneCount = 0;
		try 
		{
			var changeType = GetAmendmentType(amendmentNode);
			if(changeType == "NonTextualAmendment")
			{
				UndoCommentaryRef(selectedCommentaryId);
			}
			else
			{
				var changeId = GetAmendmentChangeId(amendmentNode);
				if(changeType == "TextualAmendment")
					changeType = GetTextualAmendmentType(changeId);
					
				switch(changeType) 
				{
					case "BlockRepeal":
					case "InlineRepeal":
						undoneCount = UndoRepeal(changeId);
						break;
						
					case "BlockAddition":
					case "InlineAddition":
						undoneCount = UndoAddition(changeId, changeType);
						break;
					
					case "BlockSubstitution":
					case "InlineSubstitution":
						undoneCount = UndoSubstitution(changeId, changeType);
						break;
				}
			}
			//remove the commentary
			if(RemoveCommentary(selectedCommentaryId, changeType))
				++undoneCount;
			//Update the task amendment		
			UpdateTaskAmendment(amendmentNode);
			++undoneCount;
		}
		catch (e)
		{	
			//Rollbacl all changes done
			if(	undoneCount > 0)
				ActiveDocument.Undo(undoneCount + 1);
			return e
		}
		return null;
	}
	
	function generateUUID()
	{
		var d = new Date().getTime();
		var uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) 
		{
			var r = (d + Math.random()*16)%16 | 0;
			d = Math.floor(d/16);
			return (c=='x' ? r : (r&0x7|0x8)).toString(16);
		});
		return uuid;
	}
	
	function GetCommentaryTextFromUser(title, promptMSG)
	{
		Application.Alert("You have not linked this amendment to a task, please add in the authority for this amendment or cancel it and associate the amendment with a task from the list below");
		var answer = Application.prompt(promptMSG, "Text here" , 100, 1024, title);
		return answer;
	}
	
	function AddUserCommentary(type, com_id, com_text)
	{
		
		var com_text_filtered = com_text.replace(/&/g, "&amp;");
		var commentariesNodeList = ActiveDocument.getNodesByXPath("//ukl:Commentaries");		
		var commentariesAdded=false;
		if (commentariesNodeList == null || commentariesNodeList.Length==0) 
		{ // no commentaries found, inserting the commentaries node
			Selection.FindInsertLocationNS ("http://www.legislation.gov.uk/namespaces/legislation","Commentaries", true);
			Selection.InsertWithTemplateNS("http://www.legislation.gov.uk/namespaces/legislation", "Commentaries")
			commentariesAdded = true;
		}
		commentariesNodeList = ActiveDocument.getNodesByXPath("//ukl:Commentaries");		
		var commentaryText  =  "<Commentary xmlns=\"http://www.legislation.gov.uk/namespaces/legislation\" id=\"" + com_id +  "\" Type=\"" +  type +"\">";
		commentaryText = commentaryText + "<Para><Text>" + com_text_filtered +  "</Text></Para></Commentary>"
		var commentariesNode = commentariesNodeList.item(0);		
		Selection.SelectNodeContents(commentariesNode);
		Selection.MoveRight();
		if (commentariesAdded)
			Selection.MoveLeft();
		Selection.PasteString(commentaryText);
	}
	
	// This is called by the macros.
	function AddDifferentCommentary(type)
	{
		var promptMSG = "Enter commentary text for " + type + " - note";
		var answer = GetCommentaryTextFromUser("EPP - Insert commentary", promptMSG);
		if(answer != "")
		{
			var cmID = "M" + "_" + type + "_" + generateUUID();
			InsertCommentaryRef(cmID);
			AddUserCommentary(type, cmID, answer);
			SetPITVersionForNonTextualAmendments(cmID);
		}
	}
	
	function PerformManualRepeal(extent, retainText)
	{
		if (Selection.Text == "") 
		  Application.Alert("No text has been selected for repeal");
		else 
		{
			var amendmentType = Application.prompt("Enter amendment type BlockRepeal or InlineRepeal", "InlineRepeal" , 40, 50, "Repeal Commentary Type");
				
			if (amendmentType != "BlockRepeal" && amendmentType != "InlineRepeal")
				Application.Alert("You can have only BlockRepeal or InlineRepeal as amendment type");
			else	
			{
				var promptMSG = "Enter commentary text for Repeal"
				var answer = GetCommentaryTextFromUser("EPP - Repeal Commentary", promptMSG);
				if(answer != "")
				{
					var selectedCommentaryId = "M_F_" + generateUUID();
					var changeId = GetNextChangeId(selectedCommentaryId);
					InsertRepeal(selectedCommentaryId, changeId, "", extent, retainText, amendmentType);
					AddUserCommentary("F", selectedCommentaryId, answer);
					Application.Clipboard.SetEmpty();
					ActiveDocument.Save();					
				}
			}
		}
	}
	
	function InsertManualAddition(amendmentType, commentaryId, changeId, extent)
	{
		InsertManualAdditionorSubstitution(amendmentType, commentaryId, changeId, extent,  "Addition");
	}
	
	function InsertManualSubstitution(amendmentType, commentaryId, changeId, extent)
	{
		InsertManualAdditionorSubstitution(amendmentType, commentaryId, changeId, extent, "Substitution");
	}
	
	function InsertManualAdditionorSubstitution(amendmentType, commentaryId, changeId, extent, tagName)
	{
		// Creating a copy range of the current selection
		var insertStartRange = Selection.Duplicate;
		// pasting the new text
		InsertNewContent("");
		
		switch(amendmentType) 
		{
			case "BlockAddition":
			case "BlockSubstitution":
				Selection.MoveRight(); // selecting the original block
				break;
			case "InlineAddition":
			case "InlineSubstitution":
				break;
		}
		
		// selecting the new text
		var insertEndRange = Selection.Duplicate;		
		insertStartRange.Select();
		Selection.ExtendTo(insertEndRange);

		switch(amendmentType) 
		{
			case "BlockAddition":
			case "BlockSubstitution":
				SetPITVersionInCurrentSelection();
				break;		
			default:
				break;
		}
		
		// reselecting the original
		insertStartRange.Select();
		Selection.ExtendTo(insertEndRange);		
		// addition tag
		InsertTagEx(insertStartRange, insertEndRange, tagName, commentaryId, changeId, amendmentType, extent);
		
		switch(amendmentType) 
		{
			case "BlockAddition":
			case "BlockSubstitution":
			case "InlineAddition":
			case "InlineSubstitution":
				SetPITVersionForTextualAmendments(changeId, amendmentType);				
				break; 
			default:					
				break;
		}
	}			
	
	function PerformManualSubstitution(retainText, isExtent) 
	{
		if (Selection.Text == "") 
			Application.Alert("No text has been selected for substitution");
		else 
		{
			if (!Application.Clipboard.HasText)
				Application.Alert("No text has been copied from the source document for substitution");      	
			else 
			{
				var extent = "";
				if(isExtent)
					extent = Application.prompt ("Enter Extent", "E");
				
				var amendmentType = Application.prompt("Enter amendment type BlockSubstitution or InlineSubstitution", "InlineSubstitution" , 40, 50, "Substitution Commentary Type");
				
				if(	amendmentType != "BlockSubstitution" && amendmentType != "InlineSubstitution")
					Application.Alert("You can have only BlockSubstitution or InlineSubstitution as amendment type");
				else	
				{
					var answer = GetCommentaryTextFromUser("EPP - Substitution Commentary", "Enter commentary text for Substitution");
					if(answer != "")
					{
						var selectedCommentaryId = 	"M_F_" + generateUUID();
						var changeIdRepeal = GetNextChangeId(selectedCommentaryId);								
						var changeIdAddition = GetChangeId(selectedCommentaryId,1);													
						// saving the current selection
						var substitutionRange = Selection.Duplicate;
						
						if (retainText) 
						{
							// inserting repeal
							InsertRepeal(selectedCommentaryId, changeIdRepeal,changeIdAddition, extent, true, amendmentType);
							
							substitutionRange.Select();
							
							// move right
							Selection.MoveRight();
							
							if (amendmentType == "InlineSubstitution" || amendmentType == "TextualAmendment")
							{
								Selection.MoveRight();
								Selection.MoveRight();
							}
									
							InsertManualAddition(amendmentType, selectedCommentaryId, changeIdAddition, extent);
							
						}
						else
						{
						// delete the selection
							Selection.Delete();
							// inserting substitution
							InsertManualSubstitution(amendmentType, selectedCommentaryId, changeIdAddition, extent);
						}
						
						AddUserCommentary("F", selectedCommentaryId, answer);
						Application.Clipboard.SetEmpty();
						ActiveDocument.Save();					
						
					}
		
				}
			}
		}		
	}
	
	function PerformAttributeReset(attributeName) 
	{
		var containerInnerName = Selection.ContainerName;
		containerInnerName = containerInnerName.replace("leg:", "");
		var currenttValue = Selection.ElementAttributeNS("", attributeName, "http://www.legislation.gov.uk/namespaces/legislation", containerInnerName, 0);
		
		if(currenttValue == "false" || currenttValue == "" )
			currenttValue = "true";
		else
			currenttValue = "false";
	
		Selection.ElementAttributeNS("", attributeName, "http://www.legislation.gov.uk/namespaces/legislation", containerInnerName, 0) = currenttValue;
		ActiveDocument.Save();
	}
	
	// Find any duplicated change IDs that are present in the document as a result of a user pasting in content
	function DeDuplicateChangeIds(elementName)
	{
		// Find all start and end repeal/addition/substitution elements that have matching change IDs
		var startNodeXPath = "//ukl:" + elementName + "[@Mark = 'Start' and @ChangeId = preceding::ukl:" + elementName + "[@Mark = 'Start']/@ChangeId]";
		var endNodeXPath = "//ukl:" + elementName + "[@Mark = 'End' and @ChangeId = preceding::ukl:" + elementName + "[@Mark = 'End']/@ChangeId]";
		
		var currentTime = new Date().getTime();
		
		UpdateDuplicatedChangeIds(startNodeXPath, currentTime);
		UpdateDuplicatedChangeIds(endNodeXPath, currentTime);
		
		// Repeal elements may also need to update substitution ref to match the amended addition change ID
		if (elementName == "Repeal")
		{
			UpdateSubstitutionRef();
		}
	}
	
	// Loop through all elements with duplicate change IDs and update them
	function UpdateDuplicatedChangeIds(nodeXPath, currentTime)
	{
		var nodesList = ActiveDocument.getNodesByXPath(nodeXPath);
		
		var length = nodesList.length;
		
		if (nodesList != null && length > 0) 
		{
			for (var i = 0; i < length; i++) 
			{
				Selection.SelectNodeContents(nodesList.item(0));
				var containerInnerName = Selection.ContainerName;
				containerInnerName = containerInnerName.replace("leg:", "");
				var commentaryId = Selection.ElementAttributeNS("", "CommentaryRef", "http://www.legislation.gov.uk/namespaces/legislation", containerInnerName);
				var changeId = commentaryId + "-" + (currentTime + i);
				Selection.ElementAttributeNS("", "ChangeId", "http://www.legislation.gov.uk/namespaces/legislation", containerInnerName, 0) = changeId;
			}
		}
	}
	
	// Find any repeal elements with substitution refs that no longer match the following addition element and update them to match
	function UpdateSubstitutionRef()
	{
		var repealStartNodeXPath = "//ukl:Repeal[@Mark = 'Start'][@ChangeId = following-sibling::ukl:Repeal[@Mark = 'End'][@SubstitutionRef != following-sibling::*[1][self::ukl:Addition]/@ChangeId]/@ChangeId]";
		var repealEndNodeXPath = "//ukl:Repeal[@Mark = 'End'][@SubstitutionRef != following-sibling::*[1][self::ukl:Addition]/@ChangeId]";
		var additionChangeIdNodeXPath = "//ukl:Repeal[@Mark = 'End'][@SubstitutionRef != following-sibling::*[1][self::ukl:Addition]/@ChangeId]/following-sibling::*[1][self::ukl:Addition]";
		
		var repealStartNodesList = ActiveDocument.getNodesByXPath(repealStartNodeXPath);
		var repealEndNodesList = ActiveDocument.getNodesByXPath(repealEndNodeXPath);
		var additionChangeIdNodesList = ActiveDocument.getNodesByXPath(additionChangeIdNodeXPath);
		
		var length = repealStartNodesList.length;
		
		if (repealEndNodesList != null && repealEndNodesList.Length > 0 && repealStartNodesList.Length == additionChangeIdNodesList.Length && repealEndNodesList.Length == additionChangeIdNodesList.Length) 
		{
			for (var i = 0; i < length; i++) 
			{
				Selection.SelectNodeContents(additionChangeIdNodesList.item(0));
				var changeId = Selection.ElementAttributeNS("", "ChangeId", "http://www.legislation.gov.uk/namespaces/legislation", "Addition");
				
				Selection.SelectNodeContents(repealStartNodesList.item(0));
				Selection.ElementAttributeNS("", "SubstitutionRef", "http://www.legislation.gov.uk/namespaces/legislation", "Repeal", 0) = changeId;
				
				Selection.SelectNodeContents(repealEndNodesList.item(0));
				Selection.ElementAttributeNS("", "SubstitutionRef", "http://www.legislation.gov.uk/namespaces/legislation", "Repeal", 0) = changeId;
			}
		}
	}
	
	function TableValidation() {
		var tables = ActiveDocument.getNodesByXPath("//xhtml:table");
		var footnotes = ActiveDocument.getNodesByXPath("//xhtml:tbody//ukl:Footnote | //xhtml:thead//ukl:Footnote");
		if (tables.Length == 0) 
		{
			Application.Alert('No tables found');
		}
		else if (footnotes.Length != 0) 
		{
			var dlgMsg = 'Footnote elements have been found in table data. These can only be used in the table footer';
			var dlgTitle = "WARNING";
			Application.Alert(dlgMsg);
			
			
		} else {
			Application.Alert('Table Validation Complete. The tables have successfully validated');
		}
	}

	function CheckIn() {
		try {
		  var legislationPlugin = null;
			legislationPlugin = new ActiveXObject("Sls.XMetaL.Legislation.LegislationPlugin");
			if (legislationPlugin == null)	throw null;
		  ActiveDocument.Save();

		  if (!legislationPlugin.CheckIn(Application.ActiveDocument.Fullname, GetSourceUri())) 
		  {
			Application.Alert("An error occurred trying to checkin: " + legislationPlugin.ErrorString);
		  }
		  else 
		  {
			ActiveDocument.Close();  
			var taskCtrl = ResourceManager.ControlInTab("Tasks");
			if (taskCtrl != null) {
				taskCtrl.Task =  "";
			}  
			Application.Alert("Document is checked in successfully");
		  }
		}
		catch (e) {		
			Application.Alert("An exception occurred while trying to checkin: " + e);
		}
		finally {

		}	
	}

]]></MACRO>

<MACRO name="On_Update_UI" lang="JScript" desc="Called when XMetaL Author starts up; the first document is opened in XMetaL Author; a different document becomes the active document in XMetaL Author; the last open document is closed in XMetaL Author; the selection moves to a different element; a command is executed; or the first character is typed into an element." hide="false"><![CDATA[// XMetal Author JScript Macro File

	var legislationPlugin = null;
	legislationPlugin = new ActiveXObject("Sls.XMetaL.Legislation.LegislationPlugin");
	if (legislationPlugin == null)	throw "XMetaL plugins are not registered";

	if (!Application.Clipboard.HasText) 
	{
	  Application.DisableMacro("EPP_Substitution");
	  Application.DisableMacro("EPP_SubstitutionRetainText");
	  Application.DisableMacro("EPP_Addition");
	  Application.DisableMacro("EPP_AdditionLimitedExtent");
	  Application.DisableMacro("EPP_SubstitutionLimitedExtent");
	  
	  Application.DisableMacro("EPP_ManualSubstitution");
	  Application.DisableMacro("EPP_ManualSubstitutionRetainText");
	  Application.DisableMacro("EPP_ManualAddition");
	  Application.DisableMacro("EPP_ManualAdditionLimitedExtent");
	  Application.DisableMacro("EPP_ManualSubstitutionLimitedExtent");
	}
    
    if (!Selection.CanInsertNS("http://www.legislation.gov.uk/namespaces/legislation", "CommentaryRef")) 
      Application.DisableMacro("Add Commentary");    
    
    if (Selection.Text == "") 
    {// if nothing is selected then substitution and repeal should be disabled
      Application.DisableMacro("EPP_Substitution");    
	  Application.DisableMacro("EPP_SubstitutionRetainText");	
	  Application.DisableMacro("EPP_SubstitutionLimitedExtent");
	  
	  
	  Application.DisableMacro("EPP_ManualSubstitution");    
	  Application.DisableMacro("EPP_ManualSubstitutionRetainText");	
	  Application.DisableMacro("EPP_ManualSubstitutionLimitedExtent");
	  
      Application.DisableMacro("EPP_Repeal");    
	  Application.DisableMacro("EPP_RepealRetainText");    
	  Application.DisableMacro("EPP_RepealLimitedExtent");
	  
	  Application.DisableMacro("EPP_Manual_Repeal");    
	  Application.DisableMacro("EPP_ManualRepealRetainText");    
	  Application.DisableMacro("EPP_ManualRepealLimitedExtent");
	  
	  Application.DisableMacro("EPP_DummyBrackets");
    }
    else 
    {// if text has been selected then disable the macro
      Application.DisableMacro("EPP_Addition");        
	  Application.DisableMacro("EPP_AdditionLimitedExtent");
	  Application.DisableMacro("EPP_InsertCommentary");        
	  Application.DisableMacro("EPP_ManualAddition");   
	  Application.DisableMacro("EPP_ManualAdditionLimitedExtent");

	  Application.DisableMacro("EPP_AddCommentary_F_Note");
	  Application.DisableMacro("EPP_AddCommentary_I_Note");
	  Application.DisableMacro("EPP_AddCommentary_C_Note");
	  Application.DisableMacro("EPP_AddCommentary_M_Note");
	  Application.DisableMacro("EPP_AddCommentary_X_Note");
	  Application.DisableMacro("EPP_AddCommentary_E_Note");
	  Application.DisableMacro("EPP_AddCommentary_P_Note");
    }

	var selectedText = Selection.Text;
	if (selectedText
		.indexOf("<Fragment ") == 0 
		|| selectedText.indexOf("<Primary ") == 0 			
		|| selectedText.indexOf("<Pnumber ") == 0 					
		|| selectedText.indexOf("<P1group ") == 0 					
		|| selectedText.indexOf("<P1 ") == 0 	
		|| selectedText.indexOf("<P2 ") == 0 
		|| selectedText.indexOf("<P3 ") == 0 
		|| selectedText.indexOf("<P4 ") == 0 		
		|| selectedText.indexOf("<P5 ") == 0 		
		|| selectedText.indexOf("<P6 ") == 0 				
		|| selectedText.indexOf("<P6 ") == 0 )		
	{
      Application.DisableMacro("EPP_Substitution");    
	  Application.DisableMacro("EPP_SubstitutionRetainText");   
	  Application.DisableMacro("EPP_SubstitutionLimitedExtent");
	  
	  Application.DisableMacro("EPP_ManualSubstitution");    
	  Application.DisableMacro("EPP_ManualSubstitutionRetainText");   
	  Application.DisableMacro("EPP_ManualSubstitutionLimitedExtent");
	  
      Application.DisableMacro("EPP_Repeal");    
	  Application.DisableMacro("EPP_RepealRetainText");    
	  Application.DisableMacro("EPP_RepealLimitedExtent");
	  
	  Application.DisableMacro("EPP_Manual_Repeal");
	  Application.DisableMacro("EPP_ManualRepealRetainText");    	  
	  Application.DisableMacro("EPP_ManualRepealLimitedExtent");
	}
	
	if (/\/correct\//.test(GetSourceUri()))
	{
		Application.DisableMacro("EPP_Addition");
		Application.DisableMacro("EPP_AdditionLimitedExtent");
		
		Application.DisableMacro("EPP_Substitution");
		Application.DisableMacro("EPP_SubstitutionRetainText");
		Application.DisableMacro("EPP_SubstitutionLimitedExtent");
		
		Application.DisableMacro("EPP_Repeal");
		Application.DisableMacro("EPP_RepealRetainText");
		Application.DisableMacro("EPP_RepealLimitedExtent");
		
		Application.DisableMacro("EPP_InsertCommentary");   
	}
	
	
	if (GetSourceUri() == "")
	  Application.DisableMacro("EPP_CheckIn");        	
]]>
</MACRO>

<MACRO name="EPP_Repeal" key="" lang="JScript" desc="To repeal the content" id="~Revisions (Custom);0:9"><![CDATA[
	function continueRepeal()
	{
		// check whether amendment has limited extent
		var limitedExtent = GetLimitedExtent(selectedAmendmentUri);
		var cancelRequest = "";
		if (limitedExtent != null)
		{
			cancelRequest = Application.prompt("This amendment has limited extent; there is a 'Limited Extent Repeal' option in the menu for repeals with limited extent. Would you like to cancel this command? [y|n}", "y"); 
		}
		else
		{
			cancelRequest = 'n'
		}
	
		if (cancelRequest == 'n')
		{
			// inserting repeal
			InsertRepeal(selectedCommentaryId, changeId, "", "", false, changetype);

			// inserting commentary
			InsertCommentary(selectedCommentaryId);
			// completing the amendment
			CompleteAmendment(amendmentNode, changeId);
				
			// clearing the clipboard and saving the document					
			Application.Clipboard.SetEmpty();
			ActiveDocument.Save();
		}
		
	}
	
	if (Selection.Text == "") 
		  Application.Alert("No text has been selected for repeal");
	else 
	{
		var selectedAmendmentUri = GetSelectedAmendmentUri();
		if (selectedAmendmentUri != "") 
		{
			var selectedCommentaryId = GetSelectedCommentaryId();
			if (selectedCommentaryId != "") 
			{
				var changeId = GetNextChangeId(selectedCommentaryId);
				var amendmentNode  = GetAmendmentNode(selectedAmendmentUri);
				var changetype = GetAmendmentType(amendmentNode);
				// if the amendment is a substitution request confirmation before continuing
				//changeType == "InlineSubstitution" || changeType == "BlockSubstitution" || changeType == "TextualAmendment"
				// check amendment is a repeal
				if (changetype =="InlineSubstitution" || changetype == "BlockSubstitution" || changetype == "TextualAmendment")
				{
					var dlgMsg = "Do you want to Repeal a Substitution Task";
					var dlgTitle = "OK to Proceed";
					var canContinue = Application.Confirm(dlgMsg,dlgTitle);
					if (canContinue) {
						
						continueRepeal()
					}
				}
				else if (changetype == "InlineRepeal" || changetype == "BlockRepeal" || changetype == "TextualAmendment")
				{
						continueRepeal()
				}
				else
				{
					Application.Alert("Current task selected is not a repeal task");
				}
			}
		}
	}
]]>
</MACRO>


<MACRO name="EPP_Substitution" key="" lang="JScript" desc="To substitute the content" id="~Revisions (Custom);0:1"><![CDATA[
	PerformSubstitution(false); 
]]>
</MACRO>

<MACRO name="EPP_SubstitutionRetainText" key="" lang="JScript" desc="While subsituting retain the text" id="~Revisions (Custom);0:5"><![CDATA[
	PerformSubstitution(true); 	
]]>
</MACRO>


<MACRO name="EPP_DummyBrackets" key="" lang="JScript" desc="Add dummy brackets around some text" id="~General (Custom);7:8">
	<![CDATA[
	
	// Ensure text has been highlighted to add dummy bracket wrapper
	if (Selection.Text == "") 
		  Application.Alert("No text has been selected to add dummy brackets around");
	else 
	{
		// Generate ID to link start and end Addition element together
		var tagName = "Addition";
		var commentaryId = "M_F_" + generateUUID();
		var changeId = GetNextChangeId(commentaryId);
		
		// Insert Addition element wrapper around selected text with no @CommentaryRef linking to an existing commentary
		InsertTag(tagName, "", changeId, "", "", "");
		ActiveDocument.Save();
	}
	
]]>
</MACRO>


<MACRO name="EPP_Addition" key="" lang="JScript" desc="add the content" id="~Revisions (Custom);0:0"><![CDATA[// XMetal Author JScript Macro File
	function continueAddition()
	{
		// check amendment has limited extent
		var limitedExtent = GetLimitedExtent(selectedAmendmentUri);
		var cancelRequest = "";
		if (limitedExtent != null)
		{
			cancelRequest = Application.prompt("This amendment has limited extent; there is a 'Limited Extent Addition' option in the menu for insertions with limited extent. Would you like to cancel this command? [y|n}", "y"); 
		}
		else
		{
			cancelRequest = 'n'
		}
		
		if (cancelRequest == 'n')
		{
			// inserting addition
			InsertAddition(amendmentNode, selectedCommentaryId, changeId, "");
			
			// inserting commentary
			InsertCommentary(selectedCommentaryId);
			
			// completing the amendment
			CompleteAmendment(amendmentNode, changeId);
			
			// clearing the clipboard and saving the document
			Application.Clipboard.SetEmpty();
			ActiveDocument.Save();
		}
	}
	
	
	if (Selection.Text != "") 
		Application.Alert("No text should be selected for addition");
	else 
	{
		if (!Application.Clipboard.HasText)
			Application.Alert("No text has been copied from the source document for addition");      	
		else 
		{
			var selectedAmendmentUri = GetSelectedAmendmentUri();
			if (selectedAmendmentUri != "") 
			{
				var selectedCommentaryId = GetSelectedCommentaryId();
				if (selectedCommentaryId != "") 
				{
					var changeId = GetNextChangeId(selectedCommentaryId);								
					var amendmentNode  = GetAmendmentNode(selectedAmendmentUri);
					
					// getting the amendment type
					var changetype = GetAmendmentType(amendmentNode);
					// for unequal subsititutions 
					if (changetype =="InlineSubstitution" || changetype == "BlockSubstitution" || changetype == "TextualAmendment")
					{
						var dlgMsg = "Do you want to Insert for a Substitution Task";
						var dlgTitle = "OK to Proceed?";
						var canContinue = Application.Confirm(dlgMsg,dlgTitle);
						if (canContinue) {
							
							continueAddition()
						}
					}
					// check amendment is an addition
					else if (changetype == "InlineAddition" || changetype == "BlockAddition" || changetype == "TextualAmendment")
					{
						continueAddition()
					}
					else
					{
						Application.Alert("Current task selected is not an addition task");
					}
				}
			}
		}
	}
]]>
</MACRO>

<MACRO name="EPP_AdditionLimitedExtent" key="" lang="JScript" desc="Addition limited extent" id="~Integration (Custom);6:4"><![CDATA[
	if (Selection.Text != "") 
		Application.Alert("No text should be selected for addition");
	else 
	{
		if (!Application.Clipboard.HasText)
			Application.Alert("No text has been copied from the source document for addition");      	
		else 
		{
			var selectedAmendmentUri = GetSelectedAmendmentUri();
			if (selectedAmendmentUri != "") 
			{
				var selectedCommentaryId = GetSelectedCommentaryId();
				if (selectedCommentaryId != "") 
				{
					var changeId = GetNextChangeId(selectedCommentaryId);								
					var amendmentNode  = GetAmendmentNode(selectedAmendmentUri);
					var changetype = GetAmendmentType(amendmentNode);
					
					// check amendment is an addition
					if (changetype == "InlineAddition" || changetype == "BlockAddition" || changetype == "TextualAmendment")
					{
						// check amendment has limited extent
						var limitedExtent = GetLimitedExtent(selectedAmendmentUri);
						var cancelRequest = "";
						if (limitedExtent == null)
						{
							cancelRequest = Application.prompt("This amendment does not have limited extent; there is an 'Addition' option in the menu for insertions without limited extent. Would you like to cancel this command? [y|n}", "y"); 
						}
						else
						{
							cancelRequest = 'n'
						}
						
						if (cancelRequest == 'n')
						{
							var answer = Application.prompt ("Enter Extent", limitedExtent);
					
							// inserting addition
							InsertAddition(amendmentNode, selectedCommentaryId, changeId, answer);
							
							// get list of added section nodes
							var addedSectionList = ActiveDocument.getNodesByXPath("//ukl:*[ukl:Title//ukl:Addition/@ChangeId='" +  changeId + "' or ukl:Number//ukl:Addition/@ChangeId='" +  changeId + "' or ukl:Pnumber//ukl:Addition/@ChangeId='" +  changeId + "' or (.//ukl:Text//ukl:Addition/@ChangeId='" +  changeId + "' and preceding-sibling::ukl:*/ukl:Title//ukl:Addition/@ChangeId='" +  changeId + "') or (preceding-sibling::ukl:*/ukl:Title//ukl:Addition/@ChangeId='" +  changeId + "' and following-sibling::ukl:*//ukl:Text//ukl:Addition/@ChangeId='" +  changeId + "')]");
							
							// iterate through list of added section nodes and add amendment extent value as @RestrictExtent value to each
							if (addedSectionList != null &&  addedSectionList.Length > 0) 
							{
								for (var i = 0; i < addedSectionList.length; i++) 
								{
									Selection.SelectNodeContents(addedSectionList.item(i));
									var containerInnerName = Selection.ContainerName;
									containerInnerName = containerInnerName.replace("leg:", "");
									Selection.ElementAttributeNS("", "RestrictExtent", "http://www.legislation.gov.uk/namespaces/legislation", containerInnerName, 0) = answer;
								}
							}
							
							// inserting commentary
							InsertCommentary(selectedCommentaryId);
							
							// completing the amendment
							CompleteAmendment(amendmentNode, changeId);
							
							// clearing the clipboard and saving the document
							Application.Clipboard.SetEmpty();
							ActiveDocument.Save();
						}
					}
					else
					{
						Application.Alert("Current task selected is not an addition task");
					}
				}
			}
		}
	}
]]>
</MACRO>


<MACRO name="On_Document_Activate" hide="true" lang="JScript"><![CDATA[
	LoadTaskList();
]]></MACRO>

<MACRO name="On_Before_Document_Preview" lang="JScript" desc="Called just before the document is previewed." hide="false"><![CDATA[// XMetal Author JScript Macro File
try {

  var legislationPlugin = null;
	legislationPlugin = new ActiveXObject("Sls.XMetaL.Legislation.LegislationPlugin");
	if (legislationPlugin == null)	throw null;

  var sourceUri = GetSourceUri();
  if (sourceUri != "") 
  {
	  ActiveDocument.Save();
	  var previewHTML = legislationPlugin.Preview(
		Application.ActiveDocument.Fullname,
		sourceUri,
		"/preview-xslt.zip",		
		"/preview-css.zip",
		1);
	  if (previewHTML == "")
	  {
		Application.Alert("An error occurred trying to generate preview: " + legislationPlugin.ErrorString);
	  }
	  else 
	  {
			ActiveDocument.BrowserURL = previewHTML;
	  }
	}
	else 
	{
		Application.Alert("Preview cannot be generated as there is no dc:source available");	
		ActiveDocument.ViewType = 2;
	}
}
catch (e) {		
    Application.Alert("An error occurred trying to preview: " + e);
}
]]></MACRO>
  
<MACRO name="On_Document_Open_Complete" lang="JScript" desc="On_Document_Open_Complete: Called after a document has been opened, but before it is displayed in a document window." hide="false"><![CDATA[// Reset values for a new document
    var taskControl = null;
	taskControl = new ActiveXObject("Sls.XMetal.Controls.TaskControl");
	if (taskControl == null)	
	{
		Application.Alert("The task control is not installed");
	}
	else 
	{
		try 
		{
			ResourceManager.AddTab("Tasks","Sls.XMetal.Controls.TaskControl");
		}
		catch (e)
		{// tab already exists
		}
		var taskCtrl = ResourceManager.ControlInTab("Tasks");
		if (taskCtrl != null) {
			taskCtrl.Application = Application;
		}		
 
	}
	ResourceManager.RemoveTab("Assets",false);
	ResourceManager.RemoveTab("Desktop",false);	
	

	LoadTaskList();
	Application.HideStructureView();
	Application.AttributeInspector.Visible = false;
    Application.ElementList.Visible = false;
    Application.HideMiniContext();
]]></MACRO>

<MACRO name="On_Document_Close" key="" lang="JScript"><![CDATA[
	var taskCtrl = ResourceManager.ControlInTab("Tasks");
	if (taskCtrl != null) {
		taskCtrl.Task =  "";	
		
		var currentDoc = ActiveDocument;
		var doc;
		var docCount = Application.Documents.Count;
		var doc_array = new Array();
		for (var x = 1; x <= docCount; x++)
			doc_array[x-1] = Application.Documents.item(x);
		
		var taskDocFound = false;
		var ClosingDocFound = 0;
		for (var x = 0; x < docCount; x++)
		{
			doc = doc_array[x];
			if (currentDoc.Title == doc.Title)
				ClosingDocFound++;
			if ((doc.Title != currentDoc.Title) || ClosingDocFound > 1)
			{
				var rulesfile = doc.RulesFile;
				var a = rulesfile.lastIndexOf("\\") + 1;
				var b = rulesfile.lastIndexOf(".");
				var dtdname = rulesfile.substring(rulesfile.lastIndexOf("\\")+1, rulesfile.lastIndexOf("."));
				if (dtdname.toLowerCase() == "fragment")
				{
					taskDocFound = true;
					break;
				}
			}
		}
		if (!taskDocFound) 
		{
			try
			{ 
				taskCtrl.Cleanup();
			}
			catch (e) {}
		}
	}
	
]]></MACRO>


  
  <MACRO name="On_Document_Open_View" lang="JScript" desc="Called once just after the document is opened and the view (Normal, Tags On, or Plain Text) is created internally by the application (but may not actually be displayed yet)." hide="false"><![CDATA[// XMetal Author JScript Macro File
// Initialise new document
ActiveDocument.ViewType = 1;
ActiveDocument.StructureViewVisible = true;
Application.ElementList.Visible = true;


]]></MACRO>


<MACRO name="On_Mouse_Out" lang="JScript" desc="Called when the user moves out of a node." hide="false">
	<![CDATA[
	
	// Deduplicate any change IDs that have been pasted into the document by a user before saving
	var changeTypes = ["Addition", "Repeal", "Substitution"];
	
	for (var i = 0; i < changeTypes.length; i++) 
	{
		DeDuplicateChangeIds(changeTypes[i]);
	}

	]]>
</MACRO>


<MACRO name="EPP_CheckIn" lang="JScript" desc="CheckIn Legislation" hide="false" desc="Check document to back to editorial content" id="~Integration (Custom);0:2"><![CDATA[// XMetal Author JScript Macro File
	var tables = ActiveDocument.getNodesByXPath("//xhtml:table");
	var footnotes = ActiveDocument.getNodesByXPath("//xhtml:tbody//ukl:Footnote | //xhtml:thead//ukl:Footnote");
	if (footnotes.Length != 0) 
		{
			var dlgMsg = 'Footnote elements have been found in table data. These can only be used in the table footer. Do you want to continue?';
			var dlgTitle = "WARNING";
			var canContinue = Application.Confirm(dlgMsg,dlgTitle);
			if (canContinue) {						
				CheckIn()
			}
		} else {CheckIn()}	

]]></MACRO>


<MACRO name="EPP_AddCommentary_F_Note" key="" desc="Insert F annotation" lang="JScript" id="~Structure (Custom);1:0">
	<![CDATA[// XMetal Author JScript Macro File
	try 
	{
		AddDifferentCommentary("F");
    }
    catch (e) {		
        Application.Alert("An error occurred trying to insert an F note: " + e);
    }
    finally {

    }    
]]>
  </MACRO>
  
  <MACRO name="EPP_AddCommentary_I_Note" key="" desc="Insert I annotation" lang="JScript" id="~Structure (Custom);1:2">
	<![CDATA[// XMetal Author JScript Macro File
	try 
	{
		AddDifferentCommentary("I");
    }
    catch (e) {		
        Application.Alert("An error occurred trying to insert an I note: " + e);
    }
    finally {

    }    
]]>
  </MACRO>
  
  <MACRO name="EPP_AddCommentary_M_Note" key="" desc="Insert M annotation" lang="JScript" id="~Structure (Custom);1:3">
	<![CDATA[// XMetal Author JScript Macro File
	try 
	{
		AddDifferentCommentary("M");
    }
    catch (e) {		
        Application.Alert("An error occurred trying to insert an M note: " + e);
    }
    finally {

    }    
]]>
  </MACRO>
  
  <MACRO name="EPP_AddCommentary_X_Note" key="" desc="Insert X annotation" lang="JScript" id="~Structure (Custom);1:4">
	<![CDATA[// XMetal Author JScript Macro File
	try 
	{
		AddDifferentCommentary("X");
    }
    catch (e) {		
        Application.Alert("An error occurred trying to insert an X note: " + e);
    }
    finally {

    }    
]]>
  </MACRO>
  
  <MACRO name="EPP_AddCommentary_E_Note" key="" desc="Insert E annotation" lang="JScript" id="~Structure (Custom);1:5">
	<![CDATA[// XMetal Author JScript Macro File
	try 
	{
		AddDifferentCommentary("E");
    }
    catch (e) {		
        Application.Alert("An error occurred trying to insert an E note: " + e);
    }
    finally {

    }    
]]>
  </MACRO>
  
  <MACRO name="EPP_AddCommentary_C_Note" key="" desc="Insert C annotation" lang="JScript" id="~Structure (Custom);1:1">
	<![CDATA[// XMetal Author JScript Macro File
	try 
	{
		AddDifferentCommentary("C");
    }
    catch (e) {		
        Application.Alert("An error occurred trying to insert an C note: " + e);
    }
    finally {

    }    
]]>
  </MACRO>
  
  <MACRO name="EPP_AddCommentary_P_Note" key="" desc="Insert P annotation" lang="JScript" id="~Structure (Custom);1:6">
	<![CDATA[// XMetal Author JScript Macro File
	try 
	{
		AddDifferentCommentary("P");
    }
    catch (e) {		
        Application.Alert("An error occurred trying to insert an P note: " + e);
    }
    finally {

    }    
]]>
  </MACRO>

 <MACRO name="EPP_SelectCommentary" key="" lang="JScript">
    <![CDATA[// XMetal Author JScript Macro File
    try {
    
	  if (Selection.ContainerName == "Addition" || Selection.ContainerName == "Repeal") 
	  {
		 var commentaryId = Selection.ElementAttributeNS("", "CommentaryRef", "http://www.legislation.gov.uk/namespaces/legislation", Selection.ContainerName, 0);

		 // move to the required place
		 var commentariesNodeList = ActiveDocument.getNodesByXPath("//ukl:Commentaries/ukl:Commentary[@id='" + commentaryId +  "']");
		 if (commentariesNodeList == null || commentariesNodeList.Length==0) 
		 { // nothing create a new node

		 }
		 else 
		 {
			var commentaryNode = commentariesNodeList.item(0);
			Selection.SelectNodeContents(commentaryNode);
		 }
	  }
      
	  
    }
    catch (e) {		
        Application.Alert("An error occurred trying to select the commentary: " + e);
    }
    finally {

    }    
]]>
  </MACRO>


<MACRO name="EPP_ShowRepeals" key="" lang="JScript">
    <![CDATA[// XMetal Author JScript Macro File
try {
	var legislationPlugin = null;
	legislationPlugin = new ActiveXObject("Sls.XMetaL.Legislation.LegislationPlugin");
	if (legislationPlugin == null)	throw null;

	legislationPlugin.ShowRepeal = 1;
	ActiveDocument.Save();

    var previewHTML = legislationPlugin.Preview(Application.ActiveDocument.Fullname,1);
    if (previewHTML == "")
	{
		Application.Alert("An error occurred trying to generate preview: " + legislationPlugin.ErrorString);
	}
	else 
	{
		if (ActiveDocument.ViewType ==3)
			ActiveDocument.Reload();			
		ActiveDocument.BrowserURL = previewHTML;
		ActiveDocument.ViewType = 3;
	}

}
catch (e) {		
	Application.Alert("An error occurred trying to enable/disable show repeals: " + e);
}
finally {

}    
]]>
  </MACRO>

<MACRO name="EPP_HideRepeals" key="" lang="JScript"><![CDATA[// XMetal Author JScript Macro File
try {
	var legislationPlugin = null;
	legislationPlugin = new ActiveXObject("Sls.XMetaL.Legislation.LegislationPlugin");
	if (legislationPlugin == null)	throw null;

	legislationPlugin.ShowRepeal = 0;
	ActiveDocument.Save();

    var previewHTML = legislationPlugin.Preview(Application.ActiveDocument.Fullname,1);
	if (previewHTML == "")
	{
		Application.Alert("An error occurred trying to generate preview: " + legislationPlugin.ErrorString);
	}
	else 
	{
		if (ActiveDocument.ViewType ==3)
			ActiveDocument.Reload();			
		ActiveDocument.BrowserURL = previewHTML;
		ActiveDocument.ViewType = 3

	}

}
catch (e) {		
	Application.Alert("An error occurred trying to enable/disable show repeals: " + e);
}
finally {

}    
]]>
</MACRO>

<MACRO name="EPP_InsertCommentary" key="" lang="JScript" desc="Insert commentary" id="~Databases (Custom);1:0"><![CDATA[
	if (Selection.Text != "") 
		Application.Alert("No Text should be selected for inserting a commentary");
	else 
	{
		var selectedAmendmentUri = GetSelectedAmendmentUri();
		if (selectedAmendmentUri != "") 
		{
			var selectedCommentaryId = GetSelectedCommentaryId();
			if (selectedCommentaryId != "") 
			{
				var amendmentNode  = GetAmendmentNode(selectedAmendmentUri);

				// inserting the commentary ref element
				InsertCommentaryRef(selectedCommentaryId);
				
				// update PIT version for parent container to inserted commentary
				SetPITVersionForNonTextualAmendments(selectedCommentaryId);
				
				// inserting commentary
				InsertCommentary(selectedCommentaryId);
				
				// completing the amendment
				CompleteAmendment(amendmentNode, selectedCommentaryId);
				
				// Saving the document					
				ActiveDocument.Save();					
			}
		}
		
	}
]]>
</MACRO>

<MACRO name="EPP_Undo" key="" lang="JScript" desc="Undo the amendment" id="~Databases (Custom);4:5"><![CDATA[
	var selectedAmendmentUri = GetSelectedAmendmentUri();
	if (selectedAmendmentUri != "") 
	{
		var selectedCommentaryId = GetSelectedCommentaryId();
		if (selectedCommentaryId != "") 
		{
			var amendmentNode  = GetAmendmentNode(selectedAmendmentUri);
			
			if(IsAmendmentComplete(amendmentNode) == false)
			{
				Application.Alert("Amendment is not completed.");
			}
			else
			{
				var error = UndoAmendment(selectedCommentaryId,amendmentNode);
				if( error != null)
					Application.Alert(" Undo amendment failed: " + error);
				ActiveDocument.Save();
			}
		}
	}
]]>
</MACRO>

<MACRO name="EPP_FlagAmendment" key="" lang="JScript" desc="Flag the amendment" id="~Revisions (Custom);1:9"><![CDATA[
	
	var selectedAmendmentUri = GetSelectedAmendmentUri();
	if (selectedAmendmentUri != "") 
	{
		var amendmentNode  = GetAmendmentNode(selectedAmendmentUri);
		var defaultValue ="";
		var noteNodeList = null; 
		if(GetAmendmentStatus(amendmentNode) == "Flagged")
		{
			noteNodeList = ActiveDocument.getNodesByXPath("//ukl:Effect/ukl:Amendment[@URI='" + selectedAmendmentUri +  "']/ukl:Note/ukl:NoteContent");
			if (noteNodeList != null && noteNodeList.Length == 1) 
				defaultValue = noteNodeList.item(0).childNodes.item(0).nodeValue;
		}
		var answer = Application.prompt ("Enter note", defaultValue);
		if(answer != "")
		{
			if (noteNodeList != null && noteNodeList.Length == 1) 
				noteNodeList.item(0).childNodes.item(0).nodeValue = answer;
			else
			{
				var noteNode = ActiveDocument.createElementNS("http://www.legislation.gov.uk/namespaces/legislation","Note");
				var noteContentNode = ActiveDocument.createElementNS("http://www.legislation.gov.uk/namespaces/legislation","NoteContent");
				var textNode = ActiveDocument.createTextNode(answer);
				noteContentNode.appendChild(textNode);
				noteNode.appendChild(noteContentNode);
				amendmentNode.appendChild(noteNode);
			}
			amendmentNode.attributes.getNamedItem("Status").nodeValue = "Flagged";
			ActiveDocument.Save();
		}
	}

]]>
</MACRO>

<MACRO name="EPP_RepealLimitedExtent" key="" lang="JScript" desc="Repeal limited extent" id="~Revisions (Custom);0:6"><![CDATA[
	if (Selection.Text == "") 
		  Application.Alert("No text has been selected for repeal");
	else 
	{
		var selectedAmendmentUri = GetSelectedAmendmentUri();
		if (selectedAmendmentUri != "") 
		{
			var selectedCommentaryId = GetSelectedCommentaryId();
			if (selectedCommentaryId != "") 
			{
				var changeId = GetNextChangeId(selectedCommentaryId);
				var amendmentNode  = GetAmendmentNode(selectedAmendmentUri);
				var changetype = GetAmendmentType(amendmentNode);
				
				// check whether amendment is a repeal
				if (changetype == "InlineRepeal" || changetype == "BlockRepeal" || changetype == "TextualAmendment")
				{
					// check whether amendment has limited extent
					var limitedExtent = GetLimitedExtent(selectedAmendmentUri);
					var cancelRequest = "";
					if (limitedExtent == null)
					{
						cancelRequest = Application.prompt("This amendment does not have limited extent; there is an 'Repeal' option in the menu for repeals without limited extent. Would you like to cancel this command? [y|n}", "y"); 
					}
					else
					{
						cancelRequest = 'n'
					}
				
					if (cancelRequest == 'n')
					{
						// confirm limited extent
						var answer = Application.prompt ("Enter Extent", limitedExtent);
				
						// inserting repeal
						InsertRepeal(selectedCommentaryId, changeId, "", answer, true, changetype);
				
						// inserting commentary
						InsertCommentary(selectedCommentaryId);
						// completing the amendment
						CompleteAmendment(amendmentNode, changeId);
					
						// clearing the clipboard and saving the document					
						Application.Clipboard.SetEmpty();
						ActiveDocument.Save();	
					}
				}
				else
				{
					Application.Alert("Current task selected is not a repeal task");
				}
			}
		}
	}
]]>
</MACRO>

<MACRO name="EPP_SubstitutionLimitedExtent" key="" lang="JScript" desc="Substitute limited extent" id="~Revisions (Custom);0:4"><![CDATA[
	if (Selection.Text == "") 
		Application.Alert("No text has been selected for substitution");
	else 
	{
		if (!Application.Clipboard.HasText)
			Application.Alert("No text has been copied from the source document for substitution");      	
		else 
		{
			var selectedAmendmentUri = GetSelectedAmendmentUri();
			if (selectedAmendmentUri != "") 
			{
				var selectedCommentaryId = GetSelectedCommentaryId();
				if (selectedCommentaryId != "") 
				{
					var changeIdRepeal = GetNextChangeId(selectedCommentaryId);								
					var changeIdAddition = GetChangeId(selectedCommentaryId,1);													
					var amendmentNode  = GetAmendmentNode(selectedAmendmentUri);
							
					// getting the amendment type
					var changeType = GetAmendmentType(amendmentNode);
					
					// check whether amendment is a substitution
					if (changeType == "InlineSubstitution" || changeType == "BlockSubstitution" || changeType == "TextualAmendment")
					{
						// check whether amendment has limited extent
						var limitedExtent = GetLimitedExtent(selectedAmendmentUri);
						var cancelRequest = "";
						if (limitedExtent == null)
						{
							cancelRequest = Application.prompt("This amendment does not have limited extent; there is an 'Substitution' option in the menu for substitutions without limited extent. Would you like to cancel this command? [y|n}", "y"); 
						}
						else
						{
							cancelRequest = 'n'
						}
				
						if (cancelRequest == 'n')
						{
							var answer = Application.prompt ("Enter Extent", limitedExtent);
							
							// saving the current selection
							var substitutionRange = Selection.Duplicate;
							
							// inserting repeal
							InsertRepeal(selectedCommentaryId, changeIdRepeal,changeIdAddition, answer, true, changeType);
							
							// get @RestrictExtent value for existing section
							var repealedSectionExtent = ActiveDocument.getNodesByXPath("//ukl:*[ukl:Title//ukl:Repeal/@ChangeId='" +  changeIdRepeal + "' or ukl:Number//ukl:Repeal/@ChangeId='" +  changeIdRepeal + "' or ukl:Pnumber//ukl:Repeal/@ChangeId='" +  changeIdRepeal + "' or self::ukl:Body or self::ukl:EUBody or parent::ukl:Primary  or parent::ukl:EURetained or parent::ukl:Secondary]/@RestrictExtent");
							var revisedSectionExtentValue;
							
							// work out appropriate extent value
							if (repealedSectionExtent == null || repealedSectionExtent.Length == 0) 
							{ 
								// no extent value found so work out default
								revisedSectionExtentValue = GetSectionExtent(answer, ""); 
							}
							else
							{
								// extent value exists
								var repealedSectionExtentAttValue = repealedSectionExtent.item(0);
								
								if (repealedSectionExtentAttValue.childNodes.length > 0)
									// getting the node value
									repealedSectionExtentValue = repealedSectionExtentAttValue.childNodes.item(0).nodeValue;
									// work out new extent value
									revisedSectionExtentValue = GetSectionExtent(answer, repealedSectionExtentValue); 
							}
							
							// get list of repealed section nodes
							var repealedSectionList = ActiveDocument.getNodesByXPath("//ukl:*[ukl:Title//ukl:Repeal/@ChangeId='" +  changeIdRepeal + "' or ukl:Number//ukl:Repeal/@ChangeId='" +  changeIdRepeal + "' or ukl:Pnumber//ukl:Repeal/@ChangeId='" +  changeIdRepeal + "' or (.//ukl:Text//ukl:Repeal/@ChangeId='" +  changeIdRepeal + "' and preceding-sibling::ukl:*/ukl:Title//ukl:Repeal/@ChangeId='" +  changeIdRepeal + "') or (preceding-sibling::ukl:*/ukl:Title//ukl:Repeal/@ChangeId='" +  changeIdRepeal + "' and following-sibling::ukl:*//ukl:Text//ukl:Repeal/@ChangeId='" +  changeIdRepeal + "')]");
							
							// iterate through list of repealed section nodes and add revised extent value as @RestrictExtent value to each
							if (repealedSectionList != null &&  repealedSectionList.Length > 0) 
							{
								for (var i = 0; i < repealedSectionList.length; i++) 
								{
									Selection.SelectNodeContents(repealedSectionList.item(i));
									var containerInnerName = Selection.ContainerName;
									containerInnerName = containerInnerName.replace("leg:", "");
									Selection.ElementAttributeNS("", "RestrictExtent", "http://www.legislation.gov.uk/namespaces/legislation", containerInnerName, 0) = revisedSectionExtentValue;
								}
							}
							
							// selecting the original block
							substitutionRange.Select();
							
							// move right
							Selection.MoveRight();
							
							if (changeType == "InlineSubstitution" || changeType == "TextualAmendment")
							{
								Selection.MoveRight();
								Selection.MoveRight();
							}
							
							// inserting addition
							InsertAddition(amendmentNode, selectedCommentaryId, changeIdAddition, answer);
							
							// get list of added section nodes
							var addedSectionList = ActiveDocument.getNodesByXPath("//ukl:*[ukl:Title//ukl:Addition/@ChangeId='" +  changeIdAddition + "' or ukl:Number//ukl:Addition/@ChangeId='" +  changeIdAddition + "' or ukl:Pnumber//ukl:Addition/@ChangeId='" +  changeIdAddition + "' or (.//ukl:Text//ukl:Addition/@ChangeId='" +  changeIdAddition + "' and preceding-sibling::ukl:*/ukl:Title//ukl:Addition/@ChangeId='" +  changeIdAddition + "') or (preceding-sibling::ukl:*/ukl:Title//ukl:Addition/@ChangeId='" +  changeIdAddition + "' and following-sibling::ukl:*//ukl:Text//ukl:Addition/@ChangeId='" +  changeIdAddition + "')]");
							
							// iterate through list of added section nodes and add amendment extent value as @RestrictExtent value to each
							if (addedSectionList != null &&  addedSectionList.Length > 0) 
							{
								for (var i = 0; i < addedSectionList.length; i++) 
								{
									Selection.SelectNodeContents(addedSectionList.item(i));
									var containerInnerName = Selection.ContainerName;
									containerInnerName = containerInnerName.replace("leg:", "");
									Selection.ElementAttributeNS("", "RestrictExtent", "http://www.legislation.gov.uk/namespaces/legislation", containerInnerName, 0) = answer;
								}
								
								InsertExtentCommentary(selectedCommentaryId, answer, revisedSectionExtentValue) 
							}
							
							// inserting commentary
							InsertCommentary(selectedCommentaryId);

							// completing the amendment
							CompleteAmendment(amendmentNode, changeIdAddition);					
							
							// clearing the clipboard and saving the document
							Application.Clipboard.SetEmpty();
							ActiveDocument.Save();
						}
					}
					else
					{
						Application.Alert("Current task selected is not a substitution task");
					}
				}
			}
		}
	}
]]>
</MACRO>

<MACRO name="EPP_RepealRetainText" key="" lang="JScript" desc="Repeal retain text" id="~Revisions (Custom);0:2"><![CDATA[
	if (Selection.Text == "") 
		  Application.Alert("No text has been selected for repeal");
	else 
	{
		var selectedAmendmentUri = GetSelectedAmendmentUri();
		if (selectedAmendmentUri != "") 
		{
			var selectedCommentaryId = GetSelectedCommentaryId();
			if (selectedCommentaryId != "") 
			{
				var changeId = GetNextChangeId(selectedCommentaryId);
				var amendmentNode  = GetAmendmentNode(selectedAmendmentUri);
				var changetype = GetAmendmentType(amendmentNode);
				
				// check whether amendment is a repeal
				if (changetype == "InlineRepeal" || changetype == "BlockRepeal" || changetype == "TextualAmendment")
				{
					// check whether amendment has limited extent
					var limitedExtent = GetLimitedExtent(selectedAmendmentUri);
					var cancelRequest = "";
					if (limitedExtent != null)
					{
						cancelRequest = Application.prompt("This amendment has limited extent; there is a 'Limited Extent Repeal' option in the menu for repeals with limited extent. Would you like to cancel this command? [y|n}", "y"); 
					}
					else
					{
						cancelRequest = 'n'
					}
						
					if (cancelRequest == 'n')
					{
						// inserting repeal
						InsertRepeal(selectedCommentaryId, changeId, "", "", true, changetype);

						// inserting commentary
						InsertCommentary(selectedCommentaryId);
						// completing the amendment
						CompleteAmendment(amendmentNode, changeId);
					
						// clearing the clipboard and saving the document					
						Application.Clipboard.SetEmpty();
						ActiveDocument.Save();
					}
				}
				else
				{
					Application.Alert("Current task selected is not a repeal task");
				}
			}
		}
	}
]]>
</MACRO>

/* All manual macros*/
<MACRO name="EPP_Manual_Repeal" key="" lang="JScript" desc="Manaully to repeal the content" id="~Revisions (Custom);0:9"><![CDATA[
	PerformManualRepeal("", false);
]]>
</MACRO>


<MACRO name="EPP_ManualRepealRetainText" key="" lang="JScript" desc="Manaul repeal retain text" id="~Revisions (Custom);0:2"><![CDATA[
	PerformManualRepeal("", true);
]]>
</MACRO>


<MACRO name="EPP_ManualRepealLimitedExtent" key="" lang="JScript" desc="Manaul repeal limited extent" id="~Revisions (Custom);0:6"><![CDATA[
	if (Selection.Text == "") 
		  Application.Alert("No text has been selected for repeal");
	else 
	{
		var extentAnswer = Application.prompt ("Enter Extent", "E");
		PerformManualRepeal(extentAnswer, true);
	}
]]>
</MACRO>


<MACRO name="EPP_ManualSubstitution" key="" lang="JScript" desc="Manually to substitute the content" id="~Revisions (Custom);0:1"><![CDATA[
	PerformManualSubstitution(false, false); 
]]>
</MACRO>

<MACRO name="EPP_ManualSubstitutionRetainText" key="" lang="JScript" desc="Manually subsituting retain the text" id="~Revisions (Custom);0:5"><![CDATA[
	PerformManualSubstitution(true, false); 	
]]>
</MACRO>

<MACRO name="EPP_ManualSubstitutionLimitedExtent" key="" lang="JScript" desc="Manually Substitute limited extent" id="~Revisions (Custom);0:4"><![CDATA[
	PerformManualSubstitution(true, true); 	
]]>
</MACRO>


<MACRO name="EPP_ManualAddition" key="" lang="JScript" desc="add the content manually" id="~Revisions (Custom);0:0"><![CDATA[

	if (Selection.Text != "") 
		Application.Alert("No text should be selected for addition");
	else 
	{
		if (!Application.Clipboard.HasText)
			Application.Alert("No text has been copied from the source document for addition");      	
		else 
		{
			var amendmentType = Application.prompt("Enter amendment type BlockAddition or InlineAddition", "InlineAddition" , 40, 50, "EPP - Addition Manual Amendment");
				
			if(	amendmentType != "BlockAddition" && amendmentType != "InlineAddition")
				Application.Alert("You can have only BlockAddition or InlineAddition as amendment type");
			else
			{
		
				var promptMSG = "Enter commentary text for Addition"
				var answer = GetCommentaryTextFromUser("EPP - Addition Commentary", promptMSG);
				if(answer != "")
				{
					var selectedCommentaryId = "M_F_" + generateUUID();
					var changeId = GetNextChangeId(selectedCommentaryId);
					var changeId = GetNextChangeId(selectedCommentaryId);	
					var changeType = amendmentType;
				
 					
					// inserting addition
					InsertManualAddition(amendmentType, selectedCommentaryId, changeId, "");
	
					AddUserCommentary("F", selectedCommentaryId, answer);
					// clearing the clipboard and saving the document					
					Application.Clipboard.SetEmpty();
					ActiveDocument.Save();		
				}
			}
		}
	}
]]>
</MACRO>

<MACRO name="EPP_ManualAdditionLimitedExtent" key="" lang="JScript" desc="Addition limited extent" id="~Integration (Custom);6:4" tooltip="EPP:Manual Addition Limited Extent"><![CDATA[
	if (Selection.Text != "") 
		Application.Alert("No text should be selected for addition");
	else 
	{
		if (!Application.Clipboard.HasText)
			Application.Alert("No text has been copied from the source document for addition");      	
		else 
		{
			var extent = Application.prompt ("Enter Extent", "E");
			var amendmentType = Application.prompt("Enter amendment type BlockAddition or InlineAddition", "InlineAddition" , 40, 50, "EPP - Addition Manual Limited Extent Amendment");
				
			if(	amendmentType != "BlockAddition" && amendmentType != "InlineAddition")
				Application.Alert("You can have only BlockAddition or InlineAddition as amendment type");
			else
			{
				var promptMSG = "Enter commentary text for Addition"
				var answer = GetCommentaryTextFromUser("EPP - Addition Commentary", promptMSG);
				if(answer != "")
				{
					var selectedCommentaryId = "M_F_" + generateUUID();
					var changeId = GetNextChangeId(selectedCommentaryId);
					var changeId = GetNextChangeId(selectedCommentaryId);								
					// inserting addition
					InsertManualAddition(amendmentType, selectedCommentaryId, changeId, extent);
					AddUserCommentary("F", selectedCommentaryId, answer);
					// clearing the clipboard and saving the document					
					Application.Clipboard.SetEmpty();
					ActiveDocument.Save();		
				}
			}
		}
	}
]]>
</MACRO>

<MACRO name="EPP_DownloadAmendingDocument" key="" lang="JScript" desc="To download amending document" id="~Integration (Custom);0:3"><![CDATA[
	var legislationPlugin = null;
	legislationPlugin = new ActiveXObject("Sls.XMetaL.Legislation.LegislationPlugin");
	if (legislationPlugin == null)	throw "XMetaL plugins are not registered";
	
	var answer = Application.prompt("Enter amending document URI. (append ?view=edit to the URI)","https://editorial.legislation.gov.uk/ukpga/1988/1/section/1/enacted/data.xml?view=edit" , 75, 1024, "EPP - Download Amending Document");
	
	if(answer != "")
	{
	    var fileName = legislationPlugin.CheckOut(answer, Application.ActiveDocument.Path);
		if(fileName != "")
			Application.Documents.Open(fileName, SQDocViewType.sqViewNormal);
		else
			Application.Alert("Unable to download the document URI:" + answer);
	}
]]>
</MACRO>

<MACRO name="EPP_SetOrResetBlanketAmendment" key="" lang="JScript" desc="Set or Reset Blanket Amendment" id="~Databases (Custom);3:0"><![CDATA[

	PerformAttributeReset("BlanketAmendment");
]]>
</MACRO>

<MACRO name="EPP_SetOrResetConfersPower" key="" lang="JScript" desc="Set or Reset Confers Power" id="~Databases (Custom);5:9"><![CDATA[

	PerformAttributeReset("ConfersPower");
			
]]>
</MACRO>

<MACRO name="EPP_ValidateTable" key="" lang="JScript" desc="Validates table content" id="~Design (Custom);3:8"><![CDATA[
	TableValidation()
]]>
</MACRO>

<MACRO name="EPP_GotoCommentary" key="" lang="JScript" desc="Locates commentary item for specific update" id="~Databases (Custom);5:8"><![CDATA[

	var containerInnerName = Selection.ContainerName;
	containerInnerName = containerInnerName.replace("leg:", "");
	
	if (containerInnerName == 'Repeal' || containerInnerName == 'Substitution' || containerInnerName == 'Addition')
	{
	
		var attr = Selection.elementAttributeNS("", "CommentaryRef", "http://www.legislation.gov.uk/namespaces/legislation", containerInnerName);
		var objNode = ActiveDocument.documentElement;
		var nodestring = "//ukl:Commentaries/ukl:Commentary[@id = '" + attr + "']";
		var commentary = objNode.getNodesByXPath(nodestring);
		
		
		for (var i =0;i<commentary.length;i++) 
				{	
					Selection.SelectNodeContents(commentary.item(i));
					var commInnerName = Selection.ContainerName;
					Selection.ContainerName;
				}
	}
	else {Application.Alert("Select an Addition, Repeal or Substitution element");}
	
	
	


	

			
]]>
</MACRO>
<MACRO name="EPP_Testforupdates" key="" lang="JScript" desc="Tests for any update element" id="~Databases (Custom);7:8"><![CDATA[
	
	function checkforupdates(containerRange) {
		for (index=0;index<containerRange.count;index++) 
		{
			var node = containerRange.NodeItem(index);
			var updates = node.getNodesByXPath("descendant-or-self::*[self::ukl:Repeal or self::ukl:Addition or self::ukl:Substitution][@Mark = 'End']");
			if ((updates != null &&  updates.Length > 0) ) {
				return "updates";
			}
		}
		
	}
	
	var containerRange = Selection.Duplicate;
	var check = checkforupdates(containerRange);
	
	
	if (check != null && check.match(/update/g)) {
		
		var dlgMsg = "This selection contains existing updates. Do you want to continue";
		var dlgTitle = "WARNING";
		var canContinue = Application.Confirm(dlgMsg,dlgTitle);
	}

		
		//for (index=0;index<containerRange.count;index++) 
		//{
		//	Application.alert(containerRange.count);
		//	var node = containerRange.NodeItem(index);
		//	var isTrue = ContainsAmendments(node, "false");
		//	Application.alert(isTrue);
		//}
		
]]>
</MACRO>
</MACROS>
