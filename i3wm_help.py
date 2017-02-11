"""
Parse the i3 config file, collect and parse shortcuts and display on screen

Author Joachim van de Haterd <joachim@derjoachim.nl>
"""
import string
import os
import gi
import collections
gi.require_version('Gtk','3.0')
from gi.repository import Gtk

class CellRendererTextWindow(Gtk.Window):
    def __init__(self,dict_config, path):
        Gtk.Window.__init__(self, title='Help ' + path)

        self.set_border_width(10)

        self.grid = Gtk.Grid()
        self.grid.set_column_homogeneous(True)
        self.grid.set_row_homogeneous(True)
        self.add(self.grid)

        hbox = Gtk.Box(spacing=6)
        self.add(hbox)
        self.set_default_size(1120,720)

        self.liststore = Gtk.ListStore(str,str)
        for sc, dscrptn in dict_config.items():
            self.liststore.append([sc, dscrptn])
         
        treeview = Gtk.TreeView(model=self.liststore)
        
        sct = Gtk.CellRendererText()
        column_text = Gtk.TreeViewColumn('Shortcut', sct, text=0)
        treeview.append_column(column_text)

        dtext = Gtk.CellRendererText()
        desc_column_text = Gtk.TreeViewColumn('Description', dtext, text=1)
        treeview.append_column(desc_column_text)

        self.add(treeview)

        button = Gtk.Button('Close')
        button.connect('clicked', self.on_close_clicked)

        self.scrollable_treelist = Gtk.ScrolledWindow()
        self.scrollable_treelist.set_vexpand(True)
        self.grid.attach(self.scrollable_treelist, 0, 0, 12, 16)
        self.grid.attach_next_to(button, self.scrollable_treelist,
                Gtk.PositionType.BOTTOM, 1, 1)
        self.scrollable_treelist.add(treeview)
        self.show_all()

    def on_close_clicked(self, button):
        Gtk.main_quit()
        

""" possible config file paths as per the i3 man page """
def getConfigPath():
    paths = ['~/.config/i3/config',
            '/etc/xdg/i3/config', 
            '~/.i3/config',
            '/etc/i3/config']

    configpath = False
    for my_path in paths:
        tmp_path = os.path.expanduser(my_path)
        if os.path.isfile(tmp_path):
            configpath = tmp_path
            break
    return configpath

"""
Open the path as found in getConfigPath and parse the shortcuts into a 
dictionary

attributes config_path the full path to the config file
"""
def parseConfigFile(config_path):
    myshortcuts = {}
    myvars = {}
    with open(config_path, encoding='utf-8') as my_file:
        for my_line in my_file:
            words = my_line.split(' ')
            if words[0] == 'set' and words[1].startswith('$'):
                myvars[words[1]] = ' '.join(words[2:]).rstrip()
            elif words[0] == 'bindsym':
                pos = 1
                if words[1].startswith('--'):
                    pos = 2
                tmpkeys = words[pos].split('+')
                for pos, subkey in enumerate(tmpkeys):
                    if subkey.startswith('$'):
                        tmpkeys[pos] = myvars[subkey]
                key = '+'.join(tmpkeys)
                myshortcuts[key] = ' '.join(words[2:]).rstrip()
    return myshortcuts


"""
Sort the config dictionary by shortcut

TODO: Mod+foo and Mod+Shift+Foo should be grouped
"""
def sortbyshortcut(dcfg):
    return collections.OrderedDict(sorted(dcfg.items()))


message = ''
current_config_path = getConfigPath()
if current_config_path == False:
    message = 'No i3wm configuration file was found'
    """ TODO Better error handling"""
else: 
    myconfig = parseConfigFile(current_config_path)
    myconfig = sortbyshortcut(myconfig)
    print(myconfig)
    
    win = CellRendererTextWindow(myconfig, current_config_path)
    win.connect('delete-event', Gtk.main_quit)
    win.show_all()
    Gtk.main()
    
