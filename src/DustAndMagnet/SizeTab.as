package DustAndMagnet
{
	import flash.events.*;
	
	import mx.containers.*;
	import mx.controls.*;
	import mx.events.*;
	
	public class SizeTab extends Canvas
	{
		private var sizeCoder:SizeCoder;
		
		private var primaryLayout:VBox;
		private var comboBox:ComboBox;
		private var controlLayout:HBox;
		private var hSlider:HSlider;
		private var removeButton:Button;
		
		private var isSizeOn:Boolean = false;
		
		
		
		public function SizeTab(sizeCoder:SizeCoder)
		{
			super();
			
			this.sizeCoder = sizeCoder;
			
			id = "size";
			label = "Size";
			
			primaryLayout = new VBox();
			primaryLayout.styleName = "PropMenu";
			primaryLayout.percentHeight = 100;
			primaryLayout.percentWidth = 100;
			addChild(primaryLayout);
			
			comboBox = new ComboBox();
			comboBox.percentWidth = 100;
			comboBox.prompt = "Please select an attribute";
			comboBox.selectedIndex = -1;
			comboBox.dataProvider = sizeCoder.getEncodableAttributes();
			comboBox.addEventListener(ListEvent.CHANGE, variableSelectionListener);
			primaryLayout.addChild(comboBox);
		}
		
		private function removeEncoding():void
		{
			sizeCoder.removeEncoding();
			
			primaryLayout.removeChild(controlLayout);
			hSlider.removeEventListener(SliderEvent.THUMB_DRAG, thumbDragListener);
			hSlider.removeEventListener(SliderEvent.CHANGE, valueChangedListener);
			removeButton.removeEventListener(MouseEvent.CLICK, removeListener)
		}
		
		private function variableSelectionListener(e:ListEvent):void
		{
			if (sizeCoder.getIsEncodingOn() == true)
			{
				removeEncoding();
			}
				
			controlLayout = new HBox();
			controlLayout.percentWidth = 100;
			primaryLayout.addChild(controlLayout);
			
			hSlider = new HSlider();
			hSlider.percentWidth = 100;
			hSlider.labels = ["Min", "Max"];
			hSlider.minimum = 0.125;       // Minimum particle radius as percentage of standard size
			hSlider.maximum = 4.00;        // Maximum particle radius as percentage of standard size
			hSlider.tickValues = [1.00];   // Place tick at neutral point
			hSlider.thumbCount = 2;
			hSlider.allowThumbOverlap = true;
			hSlider.setThumbValueAt(0, 1.00);
			hSlider.setThumbValueAt(1, 1.00);
			hSlider.showDataTip = false;
			hSlider.addEventListener(SliderEvent.THUMB_DRAG, thumbDragListener);
			hSlider.addEventListener(SliderEvent.CHANGE, valueChangedListener);
			controlLayout.addChild(hSlider);
			
			removeButton = new Button();
			removeButton.label = "Remove";
			removeButton.addEventListener(MouseEvent.CLICK, removeListener)
			controlLayout.addChild(removeButton);
			
			sizeCoder.encode(comboBox.selectedLabel);
		}
	
		private function thumbDragListener(e:SliderEvent):void
		{	
			trace("SizeCoder.thumbDragListener");
			hSlider.setThumbValueAt(e.thumbIndex, e.value);
			
			sizeCoder.setRelativeMin(Math.min(hSlider.values[0], hSlider.values[1]));
			sizeCoder.setRelativeMax(Math.max(hSlider.values[0], hSlider.values[1]));		
		}
		
		private function valueChangedListener(e:SliderEvent):void
		{
			trace("SizeCoder.valueChangedListener");
			sizeCoder.setRelativeMin(Math.min(hSlider.values[0], hSlider.values[1]));
			sizeCoder.setRelativeMax(Math.max(hSlider.values[0], hSlider.values[1]));		
		}
		
		private function removeListener(e:MouseEvent):void
		{
			removeEncoding();
			comboBox.selectedIndex = -1;
		}
	}
}