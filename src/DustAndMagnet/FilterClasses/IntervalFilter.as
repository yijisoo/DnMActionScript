// Make functions such that the minimum and maximum do not need to be found here.

package DustAndMagnet.FilterClasses
{
	import DustAndMagnet.*;
	
	public class IntervalFilter extends Filter
	{
		private var absoluteLowerBound:Number;
		private var absoluteUpperBound:Number;
		
		private var relativeLowerBound:Number;
		private var relativeUpperBound:Number;
		
		public function IntervalFilter(attribute:String, attributeKey:int, dataManager:DataManager)
		{
			super(attribute, attributeKey, dataManager);
			
			attributeType = DataManager.INTERVAL;
			
			// Find minimum of attribute
			absoluteLowerBound = absoluteUpperBound = dataManager.getData()[0][attributeKey];
			for (var i:int = 1; i < dataManager.getData().length; i++)
			{
				if (dataManager.getData()[i][attributeKey] < absoluteLowerBound)
				{
					absoluteLowerBound = dataManager.getData()[i][attributeKey];
				}
				else if (dataManager.getData()[i][attributeKey] > absoluteUpperBound)
				{
					absoluteUpperBound = dataManager.getData()[i][attributeKey];
				}
			}
			
			relativeLowerBound = absoluteLowerBound;
			relativeUpperBound = absoluteUpperBound;
		}
		
		public function getAbsoluteLowerBound():Number
		{
			return absoluteLowerBound;
		}
		
		public function getAbsoluteUpperBound():Number
		{
			return absoluteUpperBound;
		}
		
		public function getRelativeLowerBound():Number
		{
			return relativeLowerBound;
		}
		
		public function getRelativeUpperBound():Number
		{
			return relativeUpperBound;
		}
		
		public function setRelativeLowerBound(relativeLowerBound:Number):void
		{
			this.relativeLowerBound = relativeLowerBound;
			updateFilter();
		}
		
		public function setRelativeUpperBound(relativeUpperBound:Number):void
		{
			this.relativeUpperBound = relativeUpperBound;
			updateFilter();
		}
		
		protected override function updateFilter():void
		{
			for (var i:int = 0; i < dataManager.getData().length; i++)
			{
				if (dataManager.getData()[i][attributeKey] < relativeLowerBound ||
					dataManager.getData()[i][attributeKey] > relativeUpperBound)
				{
					matrix[i] = 1;		
				}
				else
				{
					matrix[i] = 0;
				}
			}
			
			super.updateFilter();
		}
	}
}