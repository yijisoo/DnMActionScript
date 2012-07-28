package DustAndMagnet
{
	import flash.events.MouseEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.collections.ArrayCollection;
	import mx.containers.*;
	import mx.controls.*;
	import mx.core.*;
	import mx.events.*;
	import mx.managers.PopUpManager;


	public class ToolBar extends Panel
	{
		private var flex:Application;
		private var visualization:VisualizationComponent;
		
		private var primaryVBox:VBox;
		private var primaryVBoxLabel:Label;
		private var secondaryVBox:VBox;
		private var secondaryVBoxLabel:Label;
		
		private var addButton:Button;
		private var deleteButton:Button;
		private var shakeButton:Button;
		private var attractButton:Button;
		private var centerButton:Button;
			
		public function ToolBar(flex:Application, visualization:VisualizationComponent)
		{
			super();
			
			this.flex = flex;
			this.visualization = visualization;
			
//			var urlLoader:URLLoader = new URLLoader();
//			var urlRequest:URLRequest = new URLRequest("assets/add.gif");
//			urlLoader.load(urlRequest);
			
			this.title = "Action";
			
			primaryVBox = new VBox();
			this.addChild(primaryVBox);
			primaryVBox.percentWidth = 100;
			primaryVBox.percentHeight = 100;
			
			primaryVBoxLabel = new Label();
			primaryVBoxLabel.text = "Magnet";
			primaryVBox.addChild(primaryVBoxLabel);
				
			addButton = new Button();
			addButton.label = "Add";
			addButton.addEventListener(MouseEvent.CLICK, addListener);
			primaryVBox.addChild(addButton);
			addButton.percentWidth = 100;
			
			deleteButton = new Button();
			deleteButton.label = "Delete";
			deleteButton.addEventListener(MouseEvent.CLICK, deleteListener);
			primaryVBox.addChild(deleteButton);
			deleteButton.percentWidth = 100;
			
			// Add dust controls.
			secondaryVBox = new VBox();
			secondaryVBox.percentWidth = 100;
			secondaryVBox.opaqueBackground = 0xCCCCCC;
			primaryVBox.addChild(secondaryVBox);
			
			secondaryVBoxLabel = new Label();
			secondaryVBoxLabel.text = "Dust";
			secondaryVBox.addChild(secondaryVBoxLabel);
			
			attractButton = new Button;
			attractButton.label = "Attract";
			attractButton.addEventListener(MouseEvent.CLICK, attractListener);
			secondaryVBox.addChild(attractButton);
			attractButton.percentWidth = 100;
			
			centerButton = new Button;
			centerButton.label = "Center";
			centerButton.addEventListener(MouseEvent.CLICK, centerListener);
			secondaryVBox.addChild(centerButton);
			centerButton.percentWidth = 100;
			
			shakeButton = new Button;
			shakeButton.label = "Shake";
			shakeButton.addEventListener(MouseEvent.CLICK, shakeListener);
			secondaryVBox.addChild(shakeButton);
			shakeButton.percentWidth = 100;
		}
		
		private function addListener(e:MouseEvent):void
		{
			var magnetList:Array;
			var magnetSelectionList:Array;
			var hashMap:Array;
			
			var popUp:TitleWindow;
			var comboBox:ComboBox;
			var label:Label = new Label();
			var okayButton:Button = new Button();
			var cancelButton:Button = new Button();
			var vBox:VBox = new VBox();
			var controlBar:ControlBar = new ControlBar();
			var spacer:Spacer = new Spacer();
            
                
			
    		magnetList = visualization.getMagnetList();
			magnetSelectionList = new Array();
			hashMap = new Array();
			
			for (var i:int = 0; i < magnetList.length; i++)
			{
				if (i == visualization.getDataManager().getPrimaryKeyIndex()) continue;
				if (magnetList[i].isActive == false)
				{
					magnetSelectionList.push(magnetList[i].getID());
					hashMap.push(magnetList[i].getAttributeKey());
				}
			}
			
			comboBox = new ComboBox();		
			comboBox.dataProvider = new ArrayCollection(magnetSelectionList);
			comboBox.prompt = "Please select an attribute";
			comboBox.selectedIndex = -1;
			
			spacer.percentWidth = 100;
			okayButton.label = "OK";
			okayButton.addEventListener(MouseEvent.CLICK, okayListener);
			cancelButton.label = "Cancel";
			cancelButton.addEventListener(MouseEvent.CLICK, cancelListener);
			controlBar.addChild(spacer);
			controlBar.addChild(okayButton)
			controlBar.addChild(cancelButton);
			
			popUp = new TitleWindow();
			popUp.layout = ContainerLayout.ABSOLUTE;
			popUp.title = "Add Magnet";       	
			popUp.addChild(comboBox);
			popUp.addChild(controlBar);
			PopUpManager.addPopUp(popUp, flex, true);
			PopUpManager.centerPopUp(popUp);
    	    
    	    function okayListener(e:MouseEvent):void
    	    {
    	    	if (comboBox.selectedIndex != -1)
    	    	{
    		    	visualization.addMagnet(hashMap[comboBox.selectedIndex]);
    	    		PopUpManager.removePopUp(popUp);
    	    		okayButton.removeEventListener(MouseEvent.CLICK, okayListener);
    	    		cancelButton.removeEventListener(MouseEvent.CLICK, cancelListener);
    	    	}
    	    }
    	      
			function cancelListener(e:MouseEvent):void
			{	
				PopUpManager.removePopUp(popUp);
				okayButton.removeEventListener(MouseEvent.CLICK, okayListener);
    	    	cancelButton.removeEventListener(MouseEvent.CLICK, cancelListener);
			}
		}
		
		private function deleteListener(e:MouseEvent):void
		{
			var magnetList:Array;
			var magnetSelectionList:Array;
			var hashMap:Array;
			
			var popUp:TitleWindow;
			var comboBox:ComboBox;
			var label:Label = new Label();
			var okayButton:Button = new Button();
			var cancelButton:Button = new Button();
			var vBox:VBox = new VBox();
			var controlBar:ControlBar = new ControlBar();
			var spacer:Spacer = new Spacer();
            
                
			
    		magnetList = visualization.getMagnetList();
			magnetSelectionList = new Array();
			hashMap = new Array();
			
			for (var i:int = 0; i < magnetList.length; i++)
			{
				if (i == visualization.getDataManager().getPrimaryKeyIndex()) continue;
				if (magnetList[i].isActive == true)
				{
					magnetSelectionList.push(magnetList[i].getID());
					hashMap.push(magnetList[i].getAttributeKey());
				}
			}
			
			comboBox = new ComboBox();		
			comboBox.dataProvider = magnetSelectionList;
			comboBox.prompt = "Please select a magnet";
			comboBox.selectedIndex = -1;
			
			spacer.percentWidth = 100;
			okayButton.label = "OK";
			okayButton.addEventListener(MouseEvent.CLICK, okayListener);
			cancelButton.label = "Cancel";
			cancelButton.addEventListener(MouseEvent.CLICK, cancelListener);
			controlBar.addChild(spacer);
			controlBar.addChild(okayButton)
			controlBar.addChild(cancelButton);
			
			popUp = new TitleWindow();
			popUp.layout = ContainerLayout.ABSOLUTE;
			popUp.title = "Delete Magnet";       	
			popUp.addChild(comboBox);
			popUp.addChild(controlBar);
			PopUpManager.addPopUp(popUp, flex, true);
			PopUpManager.centerPopUp(popUp);
    	    
    	    function okayListener(e:MouseEvent):void
    	    {
				if (comboBox.selectedIndex != -1)
				{
    	    		visualization.deleteMagnet(hashMap[comboBox.selectedIndex]);
    	  		  	PopUpManager.removePopUp(popUp);
    	    		okayButton.removeEventListener(MouseEvent.CLICK, okayListener);
    	    		cancelButton.removeEventListener(MouseEvent.CLICK, cancelListener);
  				}
    	    }
    	      
			function cancelListener(e:MouseEvent):void
			{	
				PopUpManager.removePopUp(popUp);
				okayButton.removeEventListener(MouseEvent.CLICK, okayListener);
    	    	cancelButton.removeEventListener(MouseEvent.CLICK, cancelListener);
			}
		}
		
		private function shakeListener(e:MouseEvent):void
		{
			visualization.shakeDust();
		}
		
		private function attractListener(e:MouseEvent):void
		{
			visualization.attractDust();
		}
		
		private function centerListener(e:MouseEvent):void
		{
			visualization.centerDust();
		}
	}
}