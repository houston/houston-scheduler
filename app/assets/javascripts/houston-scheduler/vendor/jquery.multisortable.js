/*
 * jquery.multisortable.js - v0.1.3
 * https://github.com/iamvery/jquery.multisortable
 *
 * Author: Ethan Atlakson, Jay Hayes
 * Last Revision 3/16/2012
 * multi-selectable, multi-sortable jQuery plugin
*/

!function($) {
	
	$.fn.multiselectable = function(options) {
		options = options || {}; 
		options = $.extend({}, $.fn.multiselectable.defaults, options)
		
		return this.each(function() {
		  var $this = $(this);
			
			if (!$this.data('multiselectable')) {
				$this.data('multiselectable', true);
				$this.delegate('> *', 'click', function(e) {
					var item = $(this),
						parent = item.parent(),
						myIndex = parent.children().index(item),
						prevIndex = parent.children().index(parent.find('.multiselectable-previous'))
					
					if (!e.ctrlKey && !e.metaKey)
						parent.find('.' + options.selectedClass).removeClass(options.selectedClass)
					else {
						if (item.not('.child').length) {
							if (item.hasClass(options.selectedClass))
								item.nextUntil(':not(.child)').removeClass(options.selectedClass)
							else
								item.nextUntil(':not(.child)').addClass(options.selectedClass)
						}
					}
					
					if (e.shiftKey && prevIndex >= 0) {
						parent.find('.multiselectable-previous').toggleClass(options.selectedClass)
						if (prevIndex < myIndex)
							item.prevUntil('.multiselectable-previous').toggleClass(options.selectedClass)
						else if (prevIndex > myIndex)
							item.nextUntil('.multiselectable-previous').toggleClass(options.selectedClass)
					} else {
  					parent.find('.multiselectable-previous').removeClass('multiselectable-previous')
  					item.addClass('multiselectable-previous')
					}
					
					item.toggleClass(options.selectedClass)
					
					options.click(e, item)
				});
				$this.children().disableSelection();
			}
		})
	}
	
	$.fn.multiselectable.defaults = {
		click: function(event, elem) {},
		selectedClass: 'selected'
	}
	
	//---
	
	$.fn.multisortable = function(options) {
		if (!options) { options = {} }
		settings = $.extend({}, $.fn.multisortable.defaults, options)
		
		function regroup(item, list) {
		  var selectedItems = list.find('.' + settings.selectedClass)
		    .css({position: '', left: '', top: '', zIndex: '', width: ''})
			if (selectedItems.length > 0) {
				var myIndex = item.data('i');
				
				var itemsBefore = selectedItems.filter(function() {
					return $(this).data('i') < myIndex
				});
				
				item.before(itemsBefore)
				
				var itemsAfter = selectedItems.filter(function() {
					return $(this).data('i') > myIndex
				});
				
				item.after(itemsAfter)
				
				setTimeout(function() {
					itemsAfter.add(itemsBefore).addClass(settings.selectedClass)
				}, 0)
			}
		}
		
		return this.each(function() {
			var list = $(this)
			
			// enable multi-selection
			list.multiselectable({selectedClass: settings.selectedClass, click: settings.click})
			
			// enable sorting
      // options.cancel = settings.items+':not(.'+settings.selectedClass+')'
			options.placeholder = settings.placeholder
			options.start = function(event, ui) {
			  var parent = ui.item.parent();
				var selectedItems = parent.find('.' + settings.selectedClass);
				var height = 0;
				
				if (!ui.item.hasClass(settings.selectedClass)) {
				  selectedItems.removeClass(settings.selectedClass);
				  ui.item.addClass(settings.selectedClass);
				  selectedItems = ui.item;
			  }
				
				// assign indexes to all selected items
				selectedItems.each(function(i) {
					$(this).data('i', i);
					height += $(this).outerHeight(true);
				})
				
				// adjust placeholder size to be size of items
				ui.placeholder.height(height);
				
				settings.start(event, ui);
			}
			
			options.stop = function(event, ui) {
				regroup(ui.item, ui.item.parent());
				settings.stop(event, ui);
			}
			
			options.sort = function(event, ui) {
				var parent = ui.item.parent(),
					  myIndex = ui.item.data('i'),
					  top = parseInt(ui.item.css('top').replace('px', '')),
					  left = parseInt(ui.item.css('left').replace('px', ''));
				
				$.fn.reverse = Array.prototype.reverse;
				var height = 0;
				$('.' + settings.selectedClass, parent).filter(function() {
					return $(this).data('i') < myIndex;
				}).reverse().each(function() {
					height += $(this).outerHeight(true);
					$(this).css({
						left: left,
						top: top - height,
						position: 'absolute',
						zIndex: 1000,
						width: ui.item.width()
					});
				});
				
				var height = ui.item.outerHeight(true);
				$('.' + settings.selectedClass, parent).filter(function() {
					return $(this).data('i') > myIndex;
				}).each(function() {
					var item = $(this);
					item.css({
						left: left,
						top: top + height,
						position: 'absolute',
						zIndex: 1000,
						width: ui.item.width()
					});
					
					height += item.outerHeight(true);
				});
				
				settings.sort(event, ui);
			}
			
			options.receive = function(event, ui) {
				regroup(ui.item, ui.sender);
				settings.receive(event, ui);
			}
			
			list.sortable(options).disableSelection();
		});
	}
	
	$.fn.multisortable.defaults = {
		start: function(event, ui) { },
		stop: function(event, ui) { },
		sort: function(event, ui) { },
		receive: function(event, ui) { },
		click: function(event, elem) { },
		selectedClass: 'selected',
		placeholder: 'placeholder',
		items: 'li'
	}
	
}(jQuery);
