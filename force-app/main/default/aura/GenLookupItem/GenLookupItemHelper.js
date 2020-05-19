({
	onItemSelect : function(component, event) {
		let onSelectEvent = component.getEvent ('lookUpOnItemSelect');
        onSelectEvent.setParams ({"selectedItem" : component.get ('v.item')});
        onSelectEvent.fire ();
	}
})