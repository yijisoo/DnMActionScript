// Written by Matt Tannahill <mtannahi@purdue.edu>
// Powered by HIVE Lab

// Point of entry.  Has reference to flex file (Flex.mxml).  Initializes components used in applications.

package
{
	import DustAndMagnet.*;
	
	import flash.events.*;
	
	import mx.containers.*;
	import mx.core.*;
	import mx.events.FlexEvent;
	
	public class MainClass
	{
		private static var dataManager:DataManager;
		private static var visualizationComponent:VisualizationComponent;
		
		// Application point of entry
		public static function main():void
		{
			// Create a reference to the Flex application
			var flex:Application = Application(FlexGlobals.topLevelApplication);
			flex.percentHeight = 100;
			flex.percentWidth = 100;
			
			// Create the title bar.
			var titleBar:Panel = new Panel();
			flex.addChild(titleBar);
			titleBar.title = "Dust & Magnet";
			titleBar.percentWidth = 100;
			titleBar.height = 30;

			// Create the application layout.
			var primaryLayout:VBox = new VBox();
			flex.addChildAt(primaryLayout, 0);
			primaryLayout.percentWidth = 100;
			primaryLayout.percentHeight = 100;
			
			var emptySpace:Container = new Container();
			primaryLayout.addChild(emptySpace);
			emptySpace.percentWidth = 100;
			emptySpace.height = titleBar.height;
			
			var secondaryLayout:HDividedBox = new HDividedBox();
			primaryLayout.addChild(secondaryLayout);
			secondaryLayout.liveDragging = true;
			secondaryLayout.percentWidth = 100;
			secondaryLayout.percentHeight = 100;
			
			var toolBarLayout:HBox = new HBox();
			secondaryLayout.addChild(toolBarLayout);
			toolBarLayout.percentWidth = 100;
			toolBarLayout.percentHeight = 100;
						
			// Add the visualization compnent.
			var visualizationPanel:Panel = new Panel();
			toolBarLayout.addChild(visualizationPanel);
			visualizationPanel.percentWidth = 100;
			visualizationPanel.percentHeight = 100;
			
			var visualization:VisualizationComponent = new VisualizationComponent();
			visualizationPanel.title = "Visualization";
			visualizationPanel.addChild(visualization);
			visualization.percentHeight = 100;
			visualization.percentWidth = 100;
			
			// Add the tool bar.
			var toolBar:ToolBar = new ToolBar(flex, visualization);
			toolBarLayout.addChild(toolBar);
			toolBar.percentHeight = 100;
			
			var tertiaryLayout:VDividedBox = new VDividedBox();
			secondaryLayout.addChild(tertiaryLayout);
			tertiaryLayout.liveDragging = true;
			tertiaryLayout.percentHeight = 100;
			tertiaryLayout.percentWidth = 50;
						
			// Create the control panel.
			var controlPanel:ControlPanel = new ControlPanel();
			tertiaryLayout.addChild(controlPanel);
			controlPanel.percentHeight = 100;
			controlPanel.percentWidth = 100;
			
			// Create the detail panel.
			var detailPanel:DetailPanel = new DetailPanel();
			tertiaryLayout.addChild(detailPanel);
			detailPanel.percentHeight = 100;
			detailPanel.percentWidth = 100;			
			
			visualization.addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteListener);
			
					
			
			function creationCompleteListener(e:Event):void
			{
				dataManager = new DataManager();
				dataManager.addEventListener(DataManager.DATA_LOAD_COMPLETE, loadDataCompleteListener);
				//dataManager.loadData("Assets/NBA.xml", "Assets/NBA_coldef.xml");
				dataManager.loadData("Assets/CerealDataTable.xml", "Assets/CerealDataSchema.xml", 1);
			}
			
			function loadDataCompleteListener(e:Event):void
			{
				trace("loadDataCompleteListener");
				visualization.addEventListener(VisualizationComponent.VISUALIZATION_INITIALIZED, visualizationInitializedListener);
				visualization.setData(dataManager);
				dataManager.removeEventListener(DataManager.DATA_LOAD_COMPLETE, loadDataCompleteListener);
			}
			
			function visualizationInitializedListener(e:Event):void
			{
				trace("visualizationInitializedListener");
				controlPanel.setVisualization(dataManager, visualization);
				detailPanel.setData(dataManager);
				detailPanel.setVisualization(visualization);
				visualization.removeEventListener(VisualizationComponent.VISUALIZATION_INITIALIZED, visualizationInitializedListener);
			}
		}
	}
}