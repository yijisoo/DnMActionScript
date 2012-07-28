// Assumptions:  comboBox.selectedIndex + 1 statements assume that the Primary Key has an index of zero.
//               The location of data type information in the data schema is fixed and known
//               Data must either be a text or a number (Future: Nominal, ordinal, interval)

package DustAndMagnet
{
	import DustAndMagnet.FilterClasses.*;
	
	import flash.display.DisplayObject;
	import flash.events.*;
	
	import mx.containers.*;
	import mx.controls.*;
	import mx.events.*;

	public class FilterTab extends Canvas
	{
		private var filterManager:FilterManager;
		
		private var primaryLayout:VBox;
		private var comboBox:ComboBox;
		
		private var filterControlLayout:Accordion;
		private var filterControls:Array = new Array();
		

		
		public function FilterTab(filterManager:FilterManager)
		{
			super();
			
			this.filterManager = filterManager;
			
			id = "filter";
			label = "Filter";
			
			primaryLayout = new VBox();
			primaryLayout.percentWidth = 100;
			primaryLayout.styleName = "PropMenu";
			addChild(primaryLayout);
			
			comboBox = new ComboBox();
			comboBox.percentWidth = 100;
			comboBox.prompt = "Please select an attribute";
			comboBox.selectedIndex = -1;
			comboBox.dataProvider = filterManager.getUnfilteredAttributes();
			comboBox.addEventListener(ListEvent.CHANGE, variableSelectionListener);
			primaryLayout.addChild(comboBox);
			
			filterControlLayout = new Accordion();			
			filterControlLayout.resizeToContent = true;
			filterControlLayout.percentWidth = 100;
			filterControlLayout.percentHeight = 100;
			primaryLayout.addChild(filterControlLayout);
		}
	
		private function variableSelectionListener(e:ListEvent):void
		{
			var filter:Filter;
			filter = filterManager.filter(comboBox.selectedLabel);
			
			filterControls.push(new VBox());
			filterControls[filterControls.length - 1].percentWidth = 100;
			filterControls[filterControls.length - 1].label = filter.getAttribute();
			filterControlLayout.addChild(filterControls[filterControls.length - 1]);
			
			var controlLayout:HBox = new HBox();
			controlLayout.percentWidth = 100;
			
			var checkList:VBox;
			var checkBox:CheckBox;
			var i:int;
			
			switch (filter.getAttributeType())
			{
				case DataManager.INTERVAL:
				{
					filterControls[filterControls.length - 1].addEventListener(SliderEvent.THUMB_DRAG, thumbDragListener, true);
					filterControls[filterControls.length - 1].addEventListener(SliderEvent.CHANGE, valueChangedListener, true);
					var slider:HSlider = new HSlider();
					slider.percentWidth = 100;
					slider.labels = ["Min", "Max"];
					slider.minimum = IntervalFilter(filterManager.getFilter(comboBox.selectedLabel)).getAbsoluteLowerBound();
					slider.maximum = IntervalFilter(filterManager.getFilter(comboBox.selectedLabel)).getAbsoluteUpperBound();
					slider.thumbCount = 2;
					slider.showDataTip = true;
					slider.allowThumbOverlap = true;
					slider.setThumbValueAt(0, IntervalFilter(filterManager.getFilter(comboBox.selectedLabel)).getRelativeLowerBound());
					slider.setThumbValueAt(1, IntervalFilter(filterManager.getFilter(comboBox.selectedLabel)).getRelativeUpperBound());
					controlLayout.addChild(slider);
					
					break;
				}
				case DataManager.ORDINAL:
				{
					filterControls[filterControls.length - 1].addEventListener(MouseEvent.CLICK, checkBoxListener);
				
					checkList = new VBox();
					checkList.percentWidth = 100;
					
					for (i = 0; i < OrdinalFilter(filterManager.getFilter(comboBox.selectedLabel)).getLevels().length; i++)
					{
						checkBox = new CheckBox();
						checkBox.label = OrdinalFilter(filterManager.getFilter(comboBox.selectedLabel)).getLevels()[i];
						checkList.addChild(checkBox);
					}
					
					controlLayout.addChild(checkList);
					
					break;
				}
				case DataManager.NOMINAL:
				{
					filterControls[filterControls.length - 1].addEventListener(MouseEvent.CLICK, checkBoxListener);
				
					checkList = new VBox();
					checkList.percentWidth = 100;
					
					for (i = 0; i < NominalFilter(filterManager.getFilter(comboBox.selectedLabel)).getLevels().length; i++)
					{
						checkBox = new CheckBox();
						checkBox.label = NominalFilter(filterManager.getFilter(comboBox.selectedLabel)).getLevels()[i];
						checkList.addChild(checkBox);
					}
					
					controlLayout.addChild(checkList);
					
					break;
				}	
				default:
				{
					throw(new Error("Datatype not found during FilterTab.variableSelectionListener()"));
				}
			}
			
			var button:Button = new Button();
			button.id = "removeButton";
			button.label = "Remove";
			filterControls[filterControls.length - 1].addEventListener(MouseEvent.CLICK, removeFilterListener);
			controlLayout.addChild(button);
			
			filterControls[filterControls.length - 1].addChild(controlLayout);
			
			var spacer:Spacer = new Spacer();
			spacer.height = 10;
			filterControls[filterControls.length - 1].addChild(spacer);
			
			comboBox.selectedIndex = -1;
			
			// Make the filter controls of the new filter visible.
			filterControlLayout.selectedIndex = filterControls.length - 1;
		}
		
		private function thumbDragListener(e:SliderEvent):void
		{
			e.target.setThumbValueAt(e.thumbIndex, e.value);
		
			var lowerBound:Number = Math.min(e.target.values[0], e.target.values[1]);
			var upperBound:Number = Math.max(e.target.values[0], e.target.values[1]);
		
			IntervalFilter(filterManager.getFilter(e.currentTarget.label)).setRelativeLowerBound(lowerBound);
			IntervalFilter(filterManager.getFilter(e.currentTarget.label)).setRelativeUpperBound(upperBound);
		}
		
		private function valueChangedListener(e:SliderEvent):void
		{
			var lowerBound:Number = Math.min(e.target.values[0], e.target.values[1]);
			var upperBound:Number = Math.max(e.target.values[0], e.target.values[1]);
		
			IntervalFilter(filterManager.getFilter(e.currentTarget.label)).setRelativeLowerBound(lowerBound);
			IntervalFilter(filterManager.getFilter(e.currentTarget.label)).setRelativeUpperBound(upperBound);
		}
		
		private function checkBoxListener(e:MouseEvent):void
		{
			if (e.target is CheckBox)
			{
				var filter:String = e.currentTarget.label;
				var level:String = e.target.label;
	
				switch(filterManager.getFilter(filter).getAttributeType())
				{
					case DataManager.ORDINAL:
						OrdinalFilter(filterManager.getFilter(filter)).setLevelFilter(level, e.target.selected);
						
						break;
					
					case DataManager.NOMINAL:
						NominalFilter(filterManager.getFilter(filter)).setLevelFilter(level, e.target.selected);
						
						break;
					
					default:
						throw(new Error("DataType not found during FilterTab.checkBoxListener()"));
				}
			}
		}
		
		private function removeFilterListener(e:MouseEvent):void
		{
			if (e.target.id == "removeButton")
			{	
				var index:int = filterControlLayout.getChildIndex(DisplayObject(e.currentTarget));
							
				e.currentTarget.removeEventListener(SliderEvent.THUMB_DRAG, thumbDragListener);
				e.currentTarget.removeEventListener(SliderEvent.CHANGE, valueChangedListener);
				e.currentTarget.removeEventListener(MouseEvent.CLICK, checkBoxListener);
				e.currentTarget.removeEventListener(MouseEvent.CLICK, removeFilterListener);

				filterControlLayout.removeChild(DisplayObject(e.currentTarget));
				filterControls.splice(index, 1);
				
				filterManager.removeFilter(e.currentTarget.label);
			}
		}
	}
}