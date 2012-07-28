package DustAndMagnet
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	public class Encoder extends EventDispatcher
	{
		protected var visualization:VisualizationComponent;
		protected var dataManager:DataManager;
		
		// levels is an array containing the levels of nominal data
		protected var levels:Array;
		
		// levelMap is an array of arrays.  An array at a particular index contains the tuple keys
		// associated with the level at the same index in the levels array.
		protected var levelMaps:Array;
		
		// List of attributes that can be color encoded		
		protected var encodableAttributes:Array;
		// List of each encodable attribute's index in data schema
		protected var hashMap:Array;
		
		// Key of encoded attribute
		protected var attributeKey:int;
		protected var attributeType:String;
		
		protected var isEncodingOn:Boolean;
		
		
		
		public function Encoder(visualization:VisualizationComponent, dataManager:DataManager, target:IEventDispatcher=null)
		{
			super(target);
		
			this.visualization = visualization;
			this.dataManager = dataManager;
			
			setEncodableAttributes();
			
			isEncodingOn = false;
		}
		
		public function getLevels():Array
		{
			return levels;
		}
		
		public function setLevels():void
		{
			var data:Array = dataManager.getData();
			
			// Create a mapping between the tuples and the attributes in the data table
			levels = new Array();
			levelMaps = new Array();
			
			var inArray:Boolean;
			for (var i:int = 0; i < data.length; i++)
			{
				inArray = false;
				for (var j:int = 0; j < levels.length; j++)
				{
					if (data[i][attributeKey] == levels[j])
					{
						inArray = true;
						break
					}
				}
				if (inArray == false)
				{
					levels.push(data[i][attributeKey]);
					levelMaps.push(new Array());
				}
			}
			levels.sort();
			
			for (i = 0; i < data.length; i++)
			{
				for (j = 0; j < levels.length; j++)
				{
					if (data[i][attributeKey] == levels[j])
					{
						levelMaps[j].push(i);
					}
				}
			}
		}
		
		public function getEncodableAttributes():Array
		{
			return encodableAttributes;
		}
		
		public function getAttributeType():String
		{
			return attributeType;
		}
		
		public function getIsEncodingOn():Boolean
		{
			return isEncodingOn
		}
		
// Abstract Methods
		public function setEncodableAttributes():void
		{
		}

		public function encode(attribute:String):void
		{
			isEncodingOn = true;
		}
		
		protected function updateEncoding():void
		{
		}
		
		public function removeEncoding():void
		{
			isEncodingOn = false;
						
			attributeKey = -1;
			attributeType = null;
		}
	}
}