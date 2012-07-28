//  Assumptions:  Primary Key is in first column.
//                The location of data type information in the data schema is fixed and known

package DustAndMagnet.FilterClasses
{
	import DustAndMagnet.*;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class Filter extends EventDispatcher
	{
		public static const FILTER_CHANGED:String = "filterChanged";
		
		protected var dataManager:DataManager;
		
		protected var attribute:String;
		protected var attributeKey:int;
		protected var attributeType:String;
		
		// If entry of matrix is 1, the datapoint is filtered; if the entry is 0, the datapoint is unfiltered.
		protected var matrix:Array;
		
		public function Filter(attribute:String, attributeKey:int, dataManager:DataManager)
		{
			this.attribute = attribute;
			this.attributeKey = attributeKey;
			this.dataManager = dataManager;
			
			// Initialize matrix.
			matrix = new Array();
			for (var i:int = 0; i < dataManager.getData().length; i++)
			{
				matrix.push(0);
			}
		}
		
		public function getAttribute():String
		{
			return attribute;
		}
		
		public function getAttributeType():String
		{
			return attributeType;
		}
		
		public function getMatrix():Array
		{
			return matrix;
		}
		
// Abstract Methods
		protected function updateFilter():void
		{
			dispatchEvent(new Event(Filter.FILTER_CHANGED));
		}
	}
}