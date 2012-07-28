package DustAndMagnet
{
	import DustAndMagnet.FilterClasses.*;
	
	import flash.events.Event;
	
	public class FilterManager
	{
		private var visualization:VisualizationComponent;
		private var dataManager:DataManager;
		
		private var unfilteredAttributes:Array;
		private var unfilteredAttributesHashMap:Array;
		private var filteredAttributes:Array;
		private var filteredAttributesHashMap:Array;
		
		// In the data filter arrays, 1 means filtered (hidden) and 0 means unfiltered (visible)
		private var filters:Array;
		
		
		
		public function FilterManager(visualization:VisualizationComponent, dataManager:DataManager)
		{
			this.visualization = visualization;
			this.dataManager = dataManager;
			
			unfilteredAttributes = new Array();
			unfilteredAttributesHashMap = new Array();
			filteredAttributes = new Array();
			filteredAttributesHashMap = new Array();
			for (var i:int = 1; i < dataManager.getDataSchema().length; i++)
			{
				unfilteredAttributes.push(dataManager.getDataSchema()[i][1]);
				unfilteredAttributesHashMap.push(i);
			}
			
			filters = new Array();
		}
		
		public function getUnfilteredAttributes():Array
		{
			return unfilteredAttributes;
		}
		
		public function getFilter(attribute:String):Filter
		{
			for (var i:int = 0; i < filters.length; i++)
			{
				if (filters[i].getAttribute() == attribute)
				{
					return filters[i];
				}
			}
			
			throw(new Error("Filter not found during FilterManager.getFilter()"));
		}
		
		public function filter(attribute:String):Filter
		{
			var attributeKey:int;
			for (var i:int; i < dataManager.getDataSchema().length; i++)
			{
// Assumes the location of the attribute names is known in the schema.
				if (dataManager.getDataSchema()[i][1] == attribute)
				{
					attributeKey = i;
				}
			}
			
			switch (dataManager.getDataSchema()[attributeKey][8])
			{
				case DataManager.INTERVAL:
					filters.push(new IntervalFilter(attribute, attributeKey, dataManager));
					
					break;
					
				case DataManager.ORDINAL:
					filters.push(new OrdinalFilter(attribute, attributeKey, dataManager));
					
					break;
					
				case DataManager.NOMINAL:
					filters.push(new NominalFilter(attribute, attributeKey, dataManager));
				
					break;
					
				default:
					throw(new Error("Datatype not found during FilterManger.filter()"));
			}
			
			filteredAttributesHashMap.push(attributeKey);
			filteredAttributes.push(attribute);
			unfilteredAttributesHashMap.splice(unfilteredAttributes.indexOf(attribute), 1);
			unfilteredAttributes.splice(unfilteredAttributes.indexOf(attribute), 1);
			
			filters[filters.length - 1].addEventListener(Filter.FILTER_CHANGED, filterChangedListener);
			
			return filters[filters.length - 1];
		}
		
		private function updateFiltering():void
		{
			var particleList:Array = visualization.getParticleList();
			
			var visibilityMatrix:Array = new Array();
			for (var i:int = 0; i < particleList.length; i++)
			{
				visibilityMatrix.push(0);
			}
			
			for (i = 0; i < filters.length; i++)
			{
				for (var j:int = 0; j < visibilityMatrix.length; j++)
				{
					if (visibilityMatrix[j] == 0 && filters[i].getMatrix()[j] == 1)
					{
						visibilityMatrix[j] = 1;
					}
				}
			}
		
			for (i = 0; i < visibilityMatrix.length; i++)
			{
				if (visibilityMatrix[i] == 1)
				{
					if (particleList[i].isVisible == true)
					{
						particleList[i].isVisible = false;
						visualization.dustLayer.removeChild(particleList[i]);
					}
				}
				else
				{
					if (particleList[i].isVisible == false)
					{
						particleList[i].isVisible = true;
						visualization.dustLayer.addChild(particleList[i]);
					}
				}
			}
		}
		
		public function removeFilter(attribute:String):void
		{
			trace("FilterManager.removeFilter");
			
			var index:int = filteredAttributes.indexOf(attribute);
			
			for(var i:int = 0; i < unfilteredAttributes.length; i++)
			{
				if (filteredAttributesHashMap[index] < unfilteredAttributesHashMap[i])
				{
					unfilteredAttributes.splice(i, 0, filteredAttributes[index]);
					unfilteredAttributesHashMap.splice(i, 0, filteredAttributesHashMap[index]);
					break;
				}
			}
			if (i == unfilteredAttributes.length)
			{
				unfilteredAttributes.push(filteredAttributes[index]);
				unfilteredAttributesHashMap.push(filteredAttributesHashMap[index]);
			}
			filteredAttributes.splice(index, 1);
			filteredAttributesHashMap.splice(index, 1);
			
			filters.splice(index, 1);
			
			updateFiltering();
		}
		
		private function filterChangedListener(e:Event):void
		{
			updateFiltering();
		}
	}
}