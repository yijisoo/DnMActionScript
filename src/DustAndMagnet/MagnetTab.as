// Assumptions:  Primary key at zero
//               Only two types of Magnets: interval and nominal


// TODO:  Check whether this class utilizes proper interfacing functions.
package DustAndMagnet
{
	import DustAndMagnet.MagnetClasses.*;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.containers.*;
	import mx.controls.*;
	import mx.events.*;

	public class MagnetTab extends Canvas
	{
		private var dataManager:DataManager;
		private var visualization:VisualizationComponent;
		
		private var primaryLayout:VBox;
		private var magnetLabel:Label;
		private var magnitudeLabel:Label;
		private var repulsionLabel:Label;
		private var magnitudeSlider:HSlider;
		private var repulsionSlider:HSlider;
		private var repulsionCheckList:VBox;
		
		private var magnetIndex:int;
		
		public function MagnetTab(dataManager:DataManager, visualization:VisualizationComponent)
		{
			super();
			
			this.dataManager = dataManager;
			this.visualization = visualization;
			visualization.addEventListener(Magnet.MAGNET_CLICKED, magnetClickedListener);
			
			id = "magnet";
			label = "Magnet";
			
			primaryLayout = new VBox();
			addChild(primaryLayout);
			primaryLayout.styleName = "PropMenu";
			primaryLayout.percentHeight = 100;
			primaryLayout.percentWidth = 100;
		}
		
		private function magnetClickedListener(e:Event):void
		{
			var i:int;
			
			// Remove all children.
			if (primaryLayout.getChildren().length > 0)
			{
				if (visualization.getMagnetList()[magnetIndex] is IntervalMagnet ||
					visualization.getMagnetList()[magnetIndex] is OrdinalMagnet)
				{
					magnitudeSlider.removeEventListener(SliderEvent.THUMB_DRAG, magnitudeThumbDragListener);
					magnitudeSlider.removeEventListener(SliderEvent.CHANGE, magnitudeValueChangedListener);
					repulsionSlider.removeEventListener(SliderEvent.THUMB_DRAG, repulsionThumbDragListener);
					repulsionSlider.removeEventListener(SliderEvent.CHANGE, repulsionValueChangedListener);
				}
				else if (visualization.getMagnetList()[magnetIndex] is NominalMagnet)
				{
					for (i = 0; i < visualization.getMagnetList()[magnetIndex].getLevels.length; i++)
					{
						repulsionCheckList.getChildAt(i).removeEventListener(MouseEvent.CLICK, checkBoxListener);
					}
				}
				
				while (primaryLayout.getChildren().length > 0)
				{
					primaryLayout.removeChildAt(0);
				}
			}
			
			magnetIndex = e.target.getAttributeKey();

			magnetLabel = new Label();
			magnetLabel.text = e.target.getID();
			primaryLayout.addChild(magnetLabel);

			magnitudeLabel = new Label();
			magnitudeLabel.text = "Magnitude";
			primaryLayout.addChild(magnitudeLabel);
			
			magnitudeSlider = new HSlider();
			magnitudeSlider.labels = ["0%", "100%"];
			magnitudeSlider.minimum = Magnet.minMagnitude;
			magnitudeSlider.maximum = Magnet.maxMagnitude;
			magnitudeSlider.thumbCount = 1;
			magnitudeSlider.showDataTip = true;
			magnitudeSlider.setThumbValueAt(0, e.target.getMagnitude());
			magnitudeSlider.percentWidth = 100;
			primaryLayout.addChild(magnitudeSlider);
			
			if (e.target is IntervalMagnet)
			{			
				repulsionLabel = new Label();
				repulsionLabel.text = "Repulsion Threshold";
				primaryLayout.addChild(repulsionLabel);
				
				var dataStatistics:Object = visualization.getDataStatistics();
				repulsionSlider = new HSlider();
				repulsionSlider.labels = ["Min", "Max"];
				repulsionSlider.minimum = dataStatistics.min[magnetIndex];
				repulsionSlider.maximum = dataStatistics.max[magnetIndex];
				repulsionSlider.thumbCount = 1;
				repulsionSlider.showDataTip = true;
				repulsionSlider.setThumbValueAt(0, e.target.repulsionThreshold);
				repulsionSlider.percentWidth = 100;
				primaryLayout.addChild(repulsionSlider);
				
				magnitudeSlider.addEventListener(SliderEvent.THUMB_DRAG, magnitudeThumbDragListener);
				magnitudeSlider.addEventListener(SliderEvent.CHANGE, magnitudeValueChangedListener);
				repulsionSlider.addEventListener(SliderEvent.THUMB_DRAG, repulsionThumbDragListener);
				repulsionSlider.addEventListener(SliderEvent.CHANGE, repulsionValueChangedListener);
			}
			else if (e.target is OrdinalMagnet)
			{
				repulsionLabel = new Label();
				repulsionLabel.text = "Repulsion Threshold";
				primaryLayout.addChild(repulsionLabel);
				
				repulsionSlider = new HSlider();
				repulsionSlider.labels = ["Min", "Max"];
				repulsionSlider.minimum = e.target.getMinLevel();
				repulsionSlider.maximum = e.target.getMaxLevel();
				repulsionSlider.thumbCount = 1;
				repulsionSlider.showDataTip = false;
				repulsionSlider.tickInterval = 1;
				repulsionSlider.snapInterval = 1;
				repulsionSlider.setThumbValueAt(0, e.target.getRepulsionThreshold());
				repulsionSlider.percentWidth = 100;
				primaryLayout.addChild(repulsionSlider);
				
				var tickValues:Array = new Array();
				for (i = 0; i < dataManager.getDataSchema()[e.target.getAttributeKey()][9].length; i++)
				{
					tickValues.push(dataManager.getDataSchema()[e.target.getAttributeKey()][9][i][1]);
				}
				repulsionSlider.labels = tickValues;
				
				magnitudeSlider.addEventListener(SliderEvent.THUMB_DRAG, magnitudeThumbDragListener);
				magnitudeSlider.addEventListener(SliderEvent.CHANGE, magnitudeValueChangedListener);
				repulsionSlider.addEventListener(SliderEvent.THUMB_DRAG, repulsionThumbDragListener);
				repulsionSlider.addEventListener(SliderEvent.CHANGE, repulsionValueChangedListener);
			}
			else if (e.target is NominalMagnet)
			{
				repulsionLabel = new Label();
				repulsionLabel.text = "Repelled Levels";
				primaryLayout.addChild(repulsionLabel);
				
				repulsionCheckList = new VBox();
				repulsionCheckList.percentWidth = 100;
				for (i = 0; i < e.target.getLevels().length; i++)
				{
					var checkBox:CheckBox = new CheckBox();
					checkBox.label = e.target.getLevels()[i];
					checkBox.addEventListener(MouseEvent.CLICK, checkBoxListener);
					checkBox.selected = e.target.getIsLevelRepelled()[i];
					repulsionCheckList.addChild(checkBox);
				}
			
				primaryLayout.addChild(repulsionCheckList);
			}
		}
		
		private function magnitudeThumbDragListener(e:SliderEvent):void
		{
			magnitudeSlider.setThumbValueAt(e.thumbIndex, e.value);
			
			visualization.getMagnetList()[magnetIndex].setMagnitude(magnitudeSlider.value);
		}
		
		private function magnitudeValueChangedListener(e:SliderEvent):void
		{
			visualization.getMagnetList()[magnetIndex].setMagnitude(magnitudeSlider.value);
		}
		
		private function repulsionThumbDragListener(e:SliderEvent):void
		{
			repulsionSlider.setThumbValueAt(e.thumbIndex, e.value);
			
			var magnetList:Array = visualization.getMagnetList();
			
			magnetList[magnetIndex].repulsionThreshold = repulsionSlider.value;
		}
		
		private function repulsionValueChangedListener(e:SliderEvent):void
		{
			var magnetList:Array = visualization.getMagnetList();
			
			magnetList[magnetIndex].repulsionThreshold = repulsionSlider.value;
		}
		
		private function checkBoxListener(e:MouseEvent):void
		{
			var magnetList:Array = visualization.getMagnetList();

			magnetList[magnetIndex].toggleRepulsion(e.target.parent.getChildIndex(e.target));
		}
	}
}