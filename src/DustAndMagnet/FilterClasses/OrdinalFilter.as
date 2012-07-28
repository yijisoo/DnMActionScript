package DustAndMagnet.FilterClasses
{
	import DustAndMagnet.DataManager;

	public class OrdinalFilter extends Filter
	{
		// levels is an array containing the levels of nominal data
		protected var levels:Array;
		
		// levelMap is an array of arrays.  An array at a particular index contains the tuple keys
		// associated with the level at the same index in the levels array.
		protected var levelMaps:Array;
		
		// Elements correspond to those in the levels array.
		// If element is 1, the level is filtered; if element is 0, the level is unfiltered.
		private var levelMatrix:Array;
		
		
		
		public function OrdinalFilter(attribute:String, attributeKey:int, dataManager:DataManager)
		{
			super(attribute, attributeKey, dataManager);
			
			attributeType = DataManager.ORDINAL;
			
			setLevels();
			
			levelMatrix = new Array();
			for (var i:int = 0; i < levels.length; i++)
			{
				levelMatrix.push(0);
			}
		}
		
		public function getLevels():Array
		{
			return levels;
		}
		
		private function setLevels():void
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
		
		public function setLevelFilter(level:String, isFiltered:int):void
		{
			levelMatrix[levels.indexOf(level)] = isFiltered;
			
			updateFilter();
		}
		
		protected override function updateFilter():void
		{
			for (var i:int = 0; i < levels.length; i++)
			{
				for (var j:int = 0; j < levelMaps[i].length; j++)
				{
					matrix[levelMaps[i][j]] = levelMatrix[i];
				}
			}
			
			super.updateFilter();
		}
	}
}