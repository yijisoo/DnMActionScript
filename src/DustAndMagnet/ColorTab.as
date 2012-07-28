// Assumptions:  comboBox.selectedIndex + 1 statements assume that the Primary Key has an index of zero.
//               The location of data type information in the data schema is fixed and known
//               Data must either be a text or a number (Future: Nominal, ordinal, interval)

package DustAndMagnet
{
	import flash.events.*;
	
	import mx.containers.*;
	import mx.controls.*;
	import mx.events.*;

	public class ColorTab extends Canvas
	{
		private var colorCoder:ColorCoder;
		
		private var primaryLayout:VBox;
		private var comboBox:ComboBox;
		private var colorControlHBoxes:Array;
		private var controlLayout:HBox;
		private var colorPickers:Array;
		private var colorPickerLayout:VBox;
		private var colorPickerLabels:Array;
		private var removeButton:Button;

		public function ColorTab(colorCoder:ColorCoder)
		{
			super();
			
			this.colorCoder = colorCoder;
			
			id = "color";
			label = "Color";
			
			primaryLayout = new VBox();
			primaryLayout.styleName = "PropMenu";
			primaryLayout.percentHeight = 100;
			primaryLayout.percentWidth = 100;
			addChild(primaryLayout);
			
			
			comboBox = new ComboBox();
			comboBox.percentWidth = 100;
			comboBox.prompt = "Please select an attribute";
			comboBox.selectedIndex = -1;
			comboBox.dataProvider = colorCoder.getEncodableAttributes();
			comboBox.addEventListener(ListEvent.CHANGE, variableSelectionListener);
			primaryLayout.addChild(comboBox);
		}
	
		private function removeEncoding():void
		{
			colorCoder.removeEncoding();
			
			switch (colorCoder.getAttributeType())
			{
				case DataManager.INTERVAL:
				case DataManager.ORDINAL:
				
					colorCoder.removeEventListener(ColorCoder.MIN_COLOR_CHANGED, minColorChangedListener);
					colorCoder.removeEventListener(ColorCoder.MAX_COLOR_CHANGED, maxColorChangedListener);
				
					break;
					
				case DataManager.NOMINAL:
				
					colorCoder.removeEventListener(ColorCoder.NOMINAL_COLOR_CHANGED, nominalColorChangedListener);
					
					break;
			}
			
			for (var i:int = 0; i < colorPickers.length; i++)
			{
				colorPickers[i].removeEventListener(ColorPickerEvent.CHANGE, colorPickerListener);
			}
			primaryLayout.removeChildAt(1);
			
			removeButton.removeEventListener(MouseEvent.CLICK, removeListener);
		}
	
		private function variableSelectionListener(e:ListEvent):void
		{
			if (colorCoder.getIsEncodingOn() == true)
			{
				removeEncoding();
			}
			
			controlLayout = new HBox();
			controlLayout.percentWidth = 100;	
			colorPickerLayout  = new VBox();
			colorPickerLayout.percentWidth = 100;		
			controlLayout.addChild(colorPickerLayout);
			primaryLayout.addChild(controlLayout);

			colorCoder.encode(comboBox.selectedLabel)
			switch (colorCoder.getAttributeType())
			{
				case DataManager.INTERVAL:
				case DataManager.ORDINAL:
					colorControlHBoxes = new Array();
					colorPickers = new Array();
					colorPickerLabels = new Array();
					
					colorControlHBoxes.push(new HBox());
					colorPickers.push(new ColorPicker());
					colorPickerLabels.push(new Label());
					colorPickerLabels[0].text = "Minimum Color";
					colorControlHBoxes[colorControlHBoxes.length - 1].addChild(colorPickers[colorPickers.length - 1]);
					colorControlHBoxes[colorControlHBoxes.length - 1].addChild(colorPickerLabels[colorPickerLabels.length - 1]);
					colorPickers[colorPickers.length - 1].addEventListener(ColorPickerEvent.CHANGE, colorPickerListener);
					colorPickerLayout.addChild(colorControlHBoxes[colorControlHBoxes.length - 1]);
					
					colorControlHBoxes.push(new HBox());
					colorPickers.push(new ColorPicker());
					colorPickerLabels.push(new Label());
					colorPickerLabels[1].text = "Maximum Color";
					colorControlHBoxes[colorControlHBoxes.length - 1].addChild(colorPickers[colorPickers.length - 1]);
					colorControlHBoxes[colorControlHBoxes.length - 1].addChild(colorPickerLabels[colorPickerLabels.length - 1]);
					colorPickers[colorPickers.length - 1].addEventListener(ColorPickerEvent.CHANGE, colorPickerListener);
					colorPickerLayout.addChild(colorControlHBoxes[colorControlHBoxes.length - 1]);
					
					colorCoder.addEventListener(ColorCoder.MIN_COLOR_CHANGED, minColorChangedListener);
					colorCoder.addEventListener(ColorCoder.MAX_COLOR_CHANGED, maxColorChangedListener);
					
					break;
			
				case DataManager.NOMINAL:
					colorControlHBoxes = new Array();
					colorPickers = new Array();
					colorPickerLabels = new Array();
					for (var i:int = 0; i < colorCoder.getLevels().length; i++)
					{
						colorControlHBoxes.push(new HBox());
						colorPickers.push(new ColorPicker());
						colorPickerLabels.push(new Label());
						colorPickerLabels[colorPickerLabels.length - 1].text = colorCoder.getLevels()[i];
						colorControlHBoxes[colorControlHBoxes.length - 1].addChild(colorPickers[colorPickers.length - 1]);
						colorControlHBoxes[colorControlHBoxes.length - 1].addChild(colorPickerLabels[colorPickerLabels.length - 1]);
						colorPickers[colorPickers.length - 1].addEventListener(ColorPickerEvent.CHANGE, colorPickerListener);
						colorPickerLayout.addChild(colorControlHBoxes[colorControlHBoxes.length - 1]);
					}
					
					colorCoder.addEventListener(ColorCoder.NOMINAL_COLOR_CHANGED, nominalColorChangedListener);
					
					break;
					
				default: 
					throw(new Error("Data Type not found during variableSelectionListener"));
			}
			
			colorCoder.assignDefaultColors();
			
			removeButton = new Button();
			removeButton.label = "Remove";
			removeButton.addEventListener(MouseEvent.CLICK, removeListener);
			controlLayout.addChild(removeButton);
		}
		
		private function colorPickerListener(e:ColorPickerEvent):void
		{
			switch (colorCoder.getAttributeType())
			{
				case DataManager.INTERVAL:
				case DataManager.ORDINAL:
					switch (colorPickers.indexOf(e.target))
					{
						case 0:
							colorCoder.setMinColor(e.color);
							break;
						
						case 1:
							colorCoder.setMaxColor(e.color);
							break;
							
						default:
							throw(new Error("ColorPicker index out of bounds for ColorTab.colorPickerListener"));
					}
					
					break;
					
				case DataManager.NOMINAL:
					var level:String = colorPickerLabels[colorPickers.indexOf(e.target)].text;
					colorCoder.setColorAt(level, e.color);
	
					break;
				
				default:
					throw(new Error("Data Type not found during variableSelectionListener"));
			}
		}
		
		private function minColorChangedListener(e:ColorCoderEvent):void
		{
			trace("minColorChangedListener");
			
			colorPickers[0].selectedColor = e.color;
		}
		
		private function maxColorChangedListener(e:ColorCoderEvent):void
		{
			trace("maxColorChangedListener");
			
			colorPickers[1].selectedColor = e.color;
		}
		
		private function nominalColorChangedListener(e:ColorCoderEvent):void
		{
			trace("nominalColorChangedListener");
			
			var index:int;
			for (var i:int = 0; i < colorPickerLabels.length; i++)
			{
				if (e.level == colorPickerLabels[i].text)
				{
					index = i;
					break;
				}
			}
			
			colorPickers[index].selectedColor = e.color;
		}
		
		private function removeListener(e:MouseEvent):void
		{
			removeEncoding();
			comboBox.selectedIndex = -1;
		}
	}
}