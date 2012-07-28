package DustAndMagnet
{
	import flare.data.*;
	
	import flash.events.*;
	import flash.net.*;
	
	public class DataManager extends EventDispatcher
	{
		public static const DATA_LOAD_COMPLETE:String = "dataLoadComplete";
		
		public static const NOMINAL:String = "nominal";
		public static const ORDINAL:String = "ordinal";
		public static const INTERVAL:String = "interval";
		
		// Array of tuples.  Each tuple is an array.
		// Each element of a tuple is data value.
		private var dataTable:Array;
		
		// Array of arrays.  Each array contains the metadata for a particular attribute.
		// Each element is structured as follows: {abbrev, desc, direction, id, name seq, short-title, title, type, {ordinal value order}}
		// Ordinal value order array is structured as flows: {{value1, string1}, {value2, string2}, ...}
		private var dataSchema:Array;
		
		// Index of the column containing the names of the data points.
		private var primaryKeyIndex:int;
		
		public function DataManager()
		{
		}
		
		public function getData():Array
		{
			return dataTable;
		}
		public function getDataSchema():Array
		{
			return dataSchema;
		}
		
		public function getPrimaryKeyIndex():int
		{
			return primaryKeyIndex;
		}
		
		private function findPrimaryKeyIndex():void
		{
// Assumptions:  Text as a primary key is easier to interpret and is preferable over a number.
		
			primaryKeyIndex = -1;
		
			// Check for string primary key
			for (var i:int = 0; i < dataSchema.length; i++)
			{
// Assumption:  I know where the data type information is in the data schema
				// Test whether a given column contains strings
				if (dataSchema[i][8] == DataManager.NOMINAL)
				{
					// If that column contains strings, test if they are all different.
					var matchDetected:Boolean = false;	
					for (var j:int = 0; j < dataTable.length - 1; j++)
					{
						for (var k:int = j + 1; k < dataTable.length; k++)
						{
							if (dataTable[j][i] == dataTable[k][i])
							{
								matchDetected = true;
								break;
							}
						} 
						
						if (matchDetected == true) break;
					}
				
					if (matchDetected == false)
					{
						primaryKeyIndex = i;
						return;
					}
				}
			}
			// If there is not a string primary key, search for a number primary key
			for (i = 0; i < dataSchema.length; i++)
			{	
				if (dataSchema[i][8] == DataManager.ORDINAL || dataSchema[i][8] == DataManager.INTERVAL)
				{
					matchDetected = false;	
					for (j = 0; j < dataTable.length - 1; j++)
					{
						for (k = j + 1; k < dataTable.length; k++)
						{
							if (dataTable[j][i] == dataTable[k][i])
							{
								matchDetected = true;
								break;
							}
						}
						
						if (matchDetected == true) break;
					}
				
					if (matchDetected == false)
					{
						primaryKeyIndex = i;
						return;
					}
				}
			}
			
			primaryKeyIndex = 0;
			
			// Primary key does not exist in data set
			//throw new Error("Error:  Primary Key not found");
		}	
		
		public function loadData(dataURL:String, schemaURL:String, _primaryKeyIndex:int = -1):void
		{
			var loadComplete:Boolean = false;
			
			var dataRequest:URLRequest = new URLRequest(dataURL);
			var dataLoader:URLLoader = new URLLoader();
			dataLoader.addEventListener(Event.COMPLETE, xmlDataLoadCompleteListener);
			dataLoader.load(dataRequest);
			
			var schemaRequest:URLRequest = new URLRequest(schemaURL);
			var schemaLoader:URLLoader = new URLLoader();
			schemaLoader.addEventListener(Event.COMPLETE, xmlSchemaLoadCompleteListener);
			schemaLoader.load(schemaRequest);
			
			function xmlDataLoadCompleteListener(e:Event):void
			{	
				trace("xmlDataLoadCompleteListener");
				var xml:XML = new XML(dataLoader.data);
				var textNode:String;
				var tuples:Array;
	
				tuples = new Array();
				for(var i:int = 0; i < xml.*.length(); i++)
				{
					tuples.push(new Array);
					for(var j:int = 0; j < xml.*[i].*.length(); j++)
					{
						textNode = xml.*[i].*[j].toString();
						tuples[i].push(DataUtil.parseValue(textNode, DataUtil.type(textNode)));
					}
				}
				dataTable = tuples;
				if (loadComplete == true)
				{
					findPrimaryKeyIndex();
					dispatchEvent(new Event(DataManager.DATA_LOAD_COMPLETE));
				}
				else
				{
					loadComplete = true;
				}
				dataLoader.removeEventListener(Event.COMPLETE, xmlDataLoadCompleteListener);
			}
			
			function xmlSchemaLoadCompleteListener(e:Event):void
			{	
				trace("xmlSchemaLoadCompleteListener");
				var xml:XML = new XML(schemaLoader.data);
				var textNode:String
				var attributes:Array;
	
//TODO: SchemaLoader should be designed to be more flexible.
	
				attributes = new Array();
				for(var i:int = 0; i < xml.*.length(); i++)
				{
					attributes.push(new Array());
					for(var j:int = 0; j < xml.*[i].*.length(); j++)
					{
						textNode = xml.*[i].*[j].toString();
						attributes[i].push(DataUtil.parseValue(textNode, DataUtil.type(textNode)));
						if (textNode == DataManager.ORDINAL)
						{
							attributes[i].push(new Array());
							for (var k:int = 0; k < xml.*[i].*[j + 1].*.length(); k++)
							{
								attributes[i][j + 1].push(new Array());
								
								textNode = xml.*[i].*[j + 1].*[k].@value.toString();
								attributes[i][j + 1][k].push(DataUtil.parseValue(textNode, DataUtil.type(textNode)));
								
								textNode = xml.*[i].*[j + 1].*[k].toString();
								attributes[i][j + 1][k].push(DataUtil.parseValue(textNode, DataUtil.type(textNode)));
							}
							
							// Sort the data.  Bubblesort used (inefficient)
							for (k = 0; k < attributes[i][j + 1].length - 1; k++)
							{
								for (var l:int = k; l < attributes[i][j + 1].length - 1; l++)
								{
									if (attributes[i][j + 1][k] > attributes[i][j + 1][k + 1])
									{
										var tempArray:Array = attributes[i][j + 1][k];
										attributes[i][j + 1].splice(k, 1);
										attributes[i][j + 1].splice(k + 1, 0, tempArray);
									}
									
								}
							}
							
							j++;
						}
					}
				}
				dataSchema = attributes;
				if (loadComplete == true)
				{
					if (_primaryKeyIndex == -1) {
						findPrimaryKeyIndex();
					}
					else { 
						primaryKeyIndex = _primaryKeyIndex;
					}
					dispatchEvent(new Event(DataManager.DATA_LOAD_COMPLETE));
				}
				else
				{
					loadComplete = true;
				}
				schemaLoader.removeEventListener(Event.COMPLETE, xmlSchemaLoadCompleteListener);
			}
		}	
	}
}