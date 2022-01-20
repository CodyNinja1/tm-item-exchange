namespace IX
{
    void PrintTree3Levels(dictionary@ tree){
        auto keys1 = tree.GetKeys();
        for(uint i = 0; i < keys1.Length; i++) {
            print(tostring(i) + ": " + keys1[i]);

            dictionary@ innerTree;
            if(!tree.Get(keys1[i], @innerTree)) {
                warn("Couldn't find key " + keys1[i] + "in tree");
                continue;
            }
            auto keys2 = innerTree.GetKeys();
            for(uint j = 0; j < keys2.Length; j++) {
                print("  - " + tostring(j) + ": " + keys2[j]);

                dictionary@ innerInnerTree;
                if(!innerTree.Get(keys2[j], @innerInnerTree)) {
                    warn("Couldn't Get<dict>() key " + keys2[j] + "in innerTree");
                    continue;
                }
                auto keys3 = innerInnerTree.GetKeys();
                for(uint k = 0; k < keys3.Length; k++) {
                    print("      - " + tostring(k) + ": " + keys3[k]);
                }
            }
        }
    }

    array<ItemTag@> ParseItemTags(Json::Value json){
        array<ItemTag@> tags = {};
        if (json.GetType() != Json::Type::Null) {
            string tagsString = json;
            string[] jTags = tagsString.Split(',');
            for(uint i=0; i<jTags.Length; i++) {
                bool found = false;
                for(uint j=0; j<m_itemTags.Length; j++) {
                    if(m_itemTags[j].ID == Text::ParseInt(jTags[i])){
                        tags.InsertLast(m_itemTags[j]);
                        found = true;
                        break;
                    }
                }
                if(!found){
                    warn("Could not find tag! " + tagsString + " -> " + jTags[i]);
                }
            }
        }
        return tags;
    }

    class Item {
        int64 ID;    //IX Item identifier
        string Name; //Name of item on IX (usually the filename minus the extensions)
        int64 UserID;    //MX UserID of uploader
        string Username; //MX Username of uploader
        string Description;   	//Description of item
        string AuthorLogin;   	//Ingame login of item creator (does not necessarily work for NadeoImporter items)
        string OriginalBlock; 	//For Blocks: The origin block of the custom block
        EItemType Type;   //IX Item Type
        string TypeName; //Name of IX Item Type
        int32 Downloads; //Total downloads of item
        ECollection Collection; //IX Collection/Environment
        string CollectionName;   //Name of IX Collection
        int32 Game;  //IX Game
        string GameName; //Name of IX Game
        int32 Score; //Item Score (Map uses + Awards on Maps)
        string FileName; //Original File Name
        string Uploaded;   //Upload Date
        string Updated;    //Last Update Date
        int64 SetID; //If != 0: Item is uploaded inside a .zip set with the SetID
        string SetName;   	//If SetID != 0: Name of the Set
        string Directory; 	//Directory inside the uploaded Set (if SetID != 0), without leading & trailing slash
        string ZipIndex;  	//CS list of indices for relevant files inside the zip if SetID != 0 (multiple means e.g. that a Shape.Gbx and a Mesh.Gbx file is included)
        bool Visible; //Item is visible and downloadable
        bool Unlisted;    //Item is hidden from search
        bool Unreleased;  //Item is hidden from search and not yet released
        int32 LikeCount; //Amount of Likes that were received for that item
        int32 CommentCount; //Amount of Comments that were received for that item
        int32 FileSize;  //Filesize of item in KB
        array<ItemTag@> Tags = {};  	//CS list of Item tags, see Get Tags method
        bool HasThumbnail;    //Indicates whether or not the item has a custom thumbnail (see Get Item Thumbnail).

        Item(const Json::Value &in json) {
            try {
                ID = json["ID"];
                Name = json["Name"];
                UserID = json["UserID"];
                Username = json["Username"];
                if (json["Description"].GetType() != Json::Type::Null) Description = json["Description"];
                if (json["AuthorLogin"].GetType() != Json::Type::Null) AuthorLogin = json["AuthorLogin"];
                if (json["OriginalBlock"].GetType() != Json::Type::Null) OriginalBlock = json["OriginalBlock"];
                Type = EItemType(int(json["Type"]));
                TypeName = json["TypeName"];
                Downloads = json["Downloads"];
                Collection = ECollection(int(json["Collection"]));
                CollectionName = json["CollectionName"];
                Game = json["Game"];
                GameName = json["GameName"];
                Score = json["Score"];
                FileName = json["FileName"];
                Uploaded = json["Uploaded"];
                Uploaded = Uploaded.Replace("T", " ");
                Updated = json["Updated"];
                Updated = Updated.Replace("T", " ");
                SetID = json["SetID"];
                if (json["SetName"].GetType() != Json::Type::Null) SetName = json["SetName"];
                if (json["Directory"].GetType() != Json::Type::Null) Directory = json["Directory"];
                if (json["ZipIndex"].GetType() != Json::Type::Null) ZipIndex = json["ZipIndex"];
                Visible = json["Visible"];
                if (json["Unlisted"].GetType() == Json::Type::Boolean) Unlisted = json["Unlisted"];
                Unreleased = json["Unreleased"];
                LikeCount = json["LikeCount"];
                CommentCount = json["CommentCount"];
                FileSize = json["FileSize"];
                HasThumbnail = json["HasThumbnail"];
                Tags = ParseItemTags(json["Tags"]);
            } catch {
                Name = json["Name"];
                mxError("Error parsing Item: "+Name);
            }
        }
    };

    //todo createcontentree is only creating 1 level of dir at a time

    // unique key that can't occur naturally in itemset content folder structure
    const string TreeItemsKey = "items_-*-_-*-_.-*-._>_<:()";
    dictionary@ CreateContentTree(IX::Item@[] items) {
        dictionary@ tree = {};
        for(uint i = 0; i < items.Length; i++) {
            auto item = items[i];
            print("Item dir: " + item.Directory);
            auto parts = item.Directory.Split("\\");
            dictionary@ node = tree;
            bool cont = false;
            // print("0 Setting current node to root");
            // create children if needed
            for(uint j = 0; j < parts.Length; j++) {
                dictionary @ childNode;
                if(node.Get(parts[j], @childNode)) {
                    // print("Not creating child node: " + parts[j]);
                    @node = childNode;
                    // print("1 Setting current node to " + parts[j]);
                } else {
                    print(parts[j] + " does not exist on this node");
                    // if child node doesn't exist yet, create
                    @childNode = {};
                    node[parts[j]] = childNode;
                    cont = true;
                    break;
                    // @node = childNode;
                    // print("Creating child node: " + parts[j]);
                    // print("2 Setting current node to " + parts[j]);
                }
            }
            if(cont) {
                i--;
                continue;
            };
            PrintTree3Levels(tree);
            // node is now equal to item directory
            IX::Item@[]@ items;
            if(!node.Get(TreeItemsKey, @items)) {
                @items = {};
                node[TreeItemsKey] = items;
            }
            items.InsertLast(item);
        }
        dictionary@ ims = cast<dictionary@>(tree['Items']);
        if(ims is null) warn("ims is null");
        print("Keys in ims: " + string::Join(ims.GetKeys(), ','));
        dictionary@ Grass = cast<dictionary@>(ims['Grass']);
        if(Grass is null) warn("Grass is null");
        print("Keys in Grass: " + string::Join(Grass.GetKeys(), ','));
        dictionary@ StartEnd = cast<dictionary@>(Grass['Start-End']);
        if(StartEnd is null) warn("StartEnd is null");
        print("Keys in startend: " + string::Join(StartEnd.GetKeys(), ','));
        dictionary@ Dirt = cast<dictionary@>(StartEnd['Dirt']);
        if(Dirt is null) warn("Dirt is null");
        IX::Item@[]@ itemsArray = cast<IX::Item@[]@>(Dirt[TreeItemsKey]);
        if(itemsArray is null) warn("itemsArray is null");
        print("Items in items>grass>start-end>dirt length: " + itemsArray.Length);
        return tree;
    }

    class ItemSet {
        int64 ID; //ItemExchange Set identifier
        string Name; //Name of the Set
        int64 UserID; //MX User identifier of set uploader
        string Username; //MX Username of set uploader
        string Description; // Description by the Set uploader (Markdown)
        int32 Downloads; //Amount of downloads of this Set
        ECollection Collection; //Collection / Environment of the included items
        string CollectionName; //Name of the Collection / Environment
        EGame Game; //Game this Set is for
        string GameName; //Name of the Game this Set is for
        int32 Score; //Total Item Score of this Set (Item map occurences + awards)
        string FileName; //Name of file (without extension, can only be .zip)
        string Uploaded; //Upload date time
        string Updated; //Update date time
        array<Item@> Items = {}; //	Items included in the Set (for doc, see Get_Item_Info method)
        bool Visible; //Set is visible
        bool Unreleased; //Set is not yet released and hidden from search
        int32 FileSize; //Total FileSize of all included Items
        int32 LikeCount; //Amount of Likes received on the Set
        int32 CommentCount; //Amount of Comments received on the Set
        array<ItemTag@> Tags = {}; //	CS list of tags (see Get_Tags method)
        int32 ImageCount; //Amount of images that are uploaded for the Set
        dictionary@ contentTree = null;

        ItemSet(const Json::Value &in json) {
            // try {
                ID = json["ID"];
                Name = json["Name"];
                UserID = json["UserID"];
                Username = json["Username"];
                if (json["Description"].GetType() != Json::Type::Null) Description = json["Description"];
                Downloads = json["Downloads"];
                Collection = ECollection(int(json["Collection"]));
                CollectionName = json["CollectionName"];
                Game = EGame(int(json["Game"]));
                GameName = json["GameName"];
                Score = json["Score"];
                FileName = json["FileName"];
                Uploaded = json["Uploaded"];
                Uploaded = Uploaded.Replace("T", " ");
                Updated = json["Updated"];
                Updated = Updated.Replace("T", " ");
                Visible = json["Visible"];
                Unreleased = json["Unreleased"];
                FileSize = json["FileSize"];
                LikeCount = json["LikeCount"];
                CommentCount = json["CommentCount"];
                ImageCount = json["ImageCount"];
                Tags = ParseItemTags(json["Tags"]);
                Items = {};
                if (json["Items"].GetType() != Json::Type::Null) {
                    auto jItems = json["Items"];
                    for(uint i=0; i<jItems.Length; i++)
                        Items.InsertLast(Item(jItems[i]));
                }
                @contentTree = CreateContentTree(Items);
            // } catch {
            //     Name = json["Name"];
            //     mxError("Error parsing ItemSet: "+Name);
            // }
        }
    };

    class ItemTag {
        int ID;
        string Name;
        string Color;

        ItemTag(const Json::Value &in json) {
            try {
                ID = json["ID"];
                Name = json["Name"];
                Color = json["Color"];
            } catch {
                Name = json["Name"];
                mxError("Error parsing tag: "+Name);
            }
        }
    };
}