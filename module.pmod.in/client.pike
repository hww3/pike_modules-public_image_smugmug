import Public.Image.SmugMug;

string version = "1.1.0";
string apikey;
string sessionid;
object xmlrpc;
object beta_xmlrpc;
int secure;

//!
static void create(string api_key, int|void use_secure)
{
  secure = use_secure;
  apikey = api_key;
  string url = "http" + (use_secure?"s":"") + "://" + XMLRPC_URL;
  xmlrpc = Protocols.XMLRPC.Client(url);  
  url = "http" + (use_secure?"s":"") + "://" + BETA_URL;
  beta_xmlrpc = Protocols.XMLRPC.Client(url);  
}

//!
void login(string email, string password)
{
  if(sessionid)
    throw(Error.Generic("SmugMug: already logged in.\n"));
  mixed res = 
  xmlrpc["smugmug.login.withPassword"](email, password, version, apikey);

  if(objectp(res))
    throw(Error.Generic("SmugMug error: " + res->fault_string + "\n"));
  else
  {
    sessionid = res[0]["SessionID"];
  }
}

//!
void login_anon()
{
  if(sessionid)
    throw(Error.Generic("SmugMug: already logged in.\n"));
  mixed res = 
  xmlrpc["smugmug.login.anonymously"](version, apikey);

  if(objectp(res))
    throw(Error.Generic("SmugMug error: " + res->fault_string + "\n"));
  else
  {
    sessionid = res[0]["SessionID"];
  }
}

//!
void logout()
{
  if(!sessionid)
    throw(Error.Generic("SmugMug: not logged in.\n"));

  mixed res = 
  xmlrpc["smugmug.logout"](sessionid);

  if(objectp(res))
    throw(Error.Generic("SmugMug error: " + res->fault_string + "\n"));
  else
  {
    sessionid = 0;
  }

}

//!
string account_type()
{
  if(!sessionid)
    throw(Error.Generic("SmugMug: not logged in.\n"));

  mixed res = 
  xmlrpc["smugmug.accounts.getType"](sessionid);

  if(objectp(res))
    throw(Error.Generic("SmugMug error: " + res->fault_string + "\n"));
  else
  {
    return res[0]->AccountType;
  }
}

//!
array get_tree(string|void nickname, int|void heavy)
{
  if(!sessionid)
    throw(Error.Generic("SmugMug: not logged in.\n"));

  array args = ({ sessionid });

  if(nickname)
  {
    args += ({nickname});

    if(heavy) args += ({heavy});
  }

  mixed res = 
  beta_xmlrpc["smugmug.users.getTree"](@args);

  if(objectp(res))
    throw(Error.Generic("SmugMug error: " + res->fault_string + "\n"));
  else
  {
    return res[0];
  }
}


//!
array get_transfer_stats(int month, int year)
{
  if(!sessionid)
    throw(Error.Generic("SmugMug: not logged in.\n"));

  mixed res = 
  beta_xmlrpc["smugmug.users.getTransferStats"](sessionid, month, year);

  if(objectp(res))
    throw(Error.Generic("SmugMug error: " + res->fault_string + "\n"));
  else
  {
    return res[0];
  }
}

//!
array get_albums(string|void nickname, int|void heavy)
{
  if(!sessionid)
    throw(Error.Generic("SmugMug: not logged in.\n"));

  array args = ({});
  object x;

  if(nickname) args += ({ nickname });
  if(heavy) {
    args += ({ heavy });
    x = beta_xmlrpc;
  }
  else
  {
    x = xmlrpc;
  }
  mixed res = 
  x["smugmug.albums.get"](sessionid, @args);


  if(objectp(res))
    throw(Error.Generic("SmugMug error: " + res->fault_string + "\n"));
  else
  {
    return res[0];
  }
}

//!
array get_album_info(int albumid)
{
  if(!sessionid)
    throw(Error.Generic("SmugMug: not logged in.\n"));

  mixed res = 
  xmlrpc["smugmug.albums.getInfo"](sessionid, albumid);

  if(objectp(res))
    throw(Error.Generic("SmugMug error: " + res->fault_string + "\n"));
  else
  {
    return res[0];
  }
}

//!
int new_album(string title, int category, void|mapping options)
{
  
  if(!sessionid)
    throw(Error.Generic("SmugMug: not logged in.\n"));

  mixed res;

  if(!options)
    res = 
    xmlrpc["smugmug.albums.create"](sessionid, title, category);
  else
    res = 
    xmlrpc["smugmug.albums.create"](sessionid, title, category, options);

  if(objectp(res))
    throw(Error.Generic("SmugMug error: " + res->fault_string + "\n"));
  else
  {
    return res[0];
  }
}

//!
int delete_album(int albumid)
{
  if(!sessionid)
    throw(Error.Generic("SmugMug: not logged in.\n"));

  mixed res = 
  xmlrpc["smugmug.albums.delete"](sessionid, albumid);

  if(objectp(res))
    throw(Error.Generic("SmugMug error: " + res->fault_string + "\n"));
  else
  {
    return (res[0]=="SUCCESS"?1:0);
  }
}

//! by values: FileName, Caption, DateTime
//! direction values: ASC, DESC
int resort_album(int albumid, string by, string direction)
{
  if(!sessionid)
    throw(Error.Generic("SmugMug: not logged in.\n"));

  if(!(<"FileName", "Caption", "DateTime">)[by])
    throw(Error.Generic("SmugMug: invalid sort by value.\n"));

  if(!(<"ASC", "DESC">)[direction])
    throw(Error.Generic("SmugMug: invalid sort direction.\n"));

  mixed res = 
  xmlrpc["smugmug.albums.reSort"](sessionid, albumid, by, direction);

  if(objectp(res))
    throw(Error.Generic("SmugMug error: " + res->fault_string + "\n"));
  else
  {
    return (res[0]);
  }
}

int change_album_settings(int albumid, mapping settings)
{
  if(!sessionid)
    throw(Error.Generic("SmugMug: not logged in.\n"));

  mixed res = 
  xmlrpc["smugmug.albums.changeSettings"](sessionid, albumid, settings);

  if(objectp(res))
    throw(Error.Generic("SmugMug error: " + res->fault_string + "\n"));
  else
  {
    return (res[0]);
  }
}

//!
mapping get_album_stats(int albumid, int month, int year, int|void heavy)
{
  if(!sessionid)
    throw(Error.Generic("SmugMug: not logged in.\n"));

  object x;

  if(heavy) x = beta_xmlrpc;
  else x = xmlrpc;

  mixed res;

  if(heavy)
    res = 
    x["smugmug.albums.getStats"](sessionid, albumid, month, year, heavy);
  else
    res = 
    x["smugmug.albums.getStats"](sessionid, albumid, month, year);

  if(objectp(res))
    throw(Error.Generic("SmugMug error: " + res->fault_string + "\n"));
  else
  {
    return res[0];
  }
}


//!
array get_album_templates()
{
  if(!sessionid)
    throw(Error.Generic("SmugMug: not logged in.\n"));

  mixed res = 
  xmlrpc["smugmug.albumtemplates.get"](sessionid);

  if(objectp(res))
    throw(Error.Generic("SmugMug error: " + res->fault_string + "\n"));
  else
  {
    return res[0];
  }
}

//!
array get_categories(string|void nickname)
{
  if(!sessionid)
    throw(Error.Generic("SmugMug: not logged in.\n"));

  array args = ({});

  if(nickname) args += ({ nickname });
  mixed res = 
  xmlrpc["smugmug.categories.get"](sessionid, @args);


  if(objectp(res))
    throw(Error.Generic("SmugMug error: " + res->fault_string + "\n"));
  else
  {
    return res[0];
  }
}

//!
int new_category(string name)
{
  
  if(!sessionid)
    throw(Error.Generic("SmugMug: not logged in.\n"));

  mixed res;

  res = 
  xmlrpc["smugmug.categories.create"](sessionid, name);

  if(objectp(res))
    throw(Error.Generic("SmugMug error: " + res->fault_string + "\n"));
  else
  {
    return res[0];
  }
}

//!
int delete_category(int categoryid)
{
  if(!sessionid)
    throw(Error.Generic("SmugMug: not logged in.\n"));

  mixed res = 
  xmlrpc["smugmug.categories.delete"](sessionid, categoryid);

  if(objectp(res))
    throw(Error.Generic("SmugMug error: " + res->fault_string + "\n"));
  else
  {
    return (res[0]=="SUCCESS"?1:0);
  }
}

//!
int rename_category(int categoryid, string newname)
{
  if(!sessionid)
    throw(Error.Generic("SmugMug: not logged in.\n"));

  mixed res = 
  xmlrpc["smugmug.categories.rename"](sessionid, categoryid, newname);

  if(objectp(res))
    throw(Error.Generic("SmugMug error: " + res->fault_string + "\n"));
  else
  {
    return (res[0]=="SUCCESS"?1:0);
  }
}

//!
array get_subcategories(int categoryid, string|void nickname)
{
  if(!sessionid)
    throw(Error.Generic("SmugMug: not logged in.\n"));

  array args = ({});

  if(nickname) args += ({ nickname });
  mixed res = 
  xmlrpc["smugmug.subcategories.get"](sessionid, categoryid, @args);


  if(objectp(res))
    throw(Error.Generic("SmugMug error: " + res->fault_string + "\n"));
  else
  {
    return res[0];
  }
}

//!
array get_all_subcategories(string|void nickname)
{
  if(!sessionid)
    throw(Error.Generic("SmugMug: not logged in.\n"));

  array args = ({});

  if(nickname) args += ({ nickname });
  mixed res = 
  xmlrpc["smugmug.subcategories.getAll"](sessionid, @args);


  if(objectp(res))
    throw(Error.Generic("SmugMug error: " + res->fault_string + "\n"));
  else
  {
    return res[0];
  }
}


//!
int new_subcategory(string name, int categoryid)
{
  
  if(!sessionid)
    throw(Error.Generic("SmugMug: not logged in.\n"));

  mixed res;

  res = 
  xmlrpc["smugmug.subcategories.create"](sessionid, name, categoryid);

  if(objectp(res))
    throw(Error.Generic("SmugMug error: " + res->fault_string + "\n"));
  else
  {
    return res[0];
  }
}

//!
int delete_subcategory(int subcategoryid)
{
  if(!sessionid)
    throw(Error.Generic("SmugMug: not logged in.\n"));

  mixed res = 
  xmlrpc["smugmug.subcategories.delete"](sessionid, subcategoryid);

  if(objectp(res))
    throw(Error.Generic("SmugMug error: " + res->fault_string + "\n"));
  else
  {
    return (res[0]=="SUCCESS"?1:0);
  }
}

//!
int rename_subcategory(int subcategoryid, string newname)
{
  if(!sessionid)
    throw(Error.Generic("SmugMug: not logged in.\n"));

  mixed res = 
  xmlrpc["smugmug.subcategories.rename"](sessionid, subcategoryid, newname);

  if(objectp(res))
    throw(Error.Generic("SmugMug error: " + res->fault_string + "\n"));
  else
  {
    return (res[0]=="SUCCESS"?1:0);
  }
}

array get_images(int albumid, int|void heavy)
{
  if(!sessionid)
    throw(Error.Generic("SmugMug: not logged in.\n"));

  mixed res;

  if(heavy)
  {
    res = beta_xmlrpc["smugmug.images.get"](sessionid, albumid, heavy);
  }
  else
  {
    res = xmlrpc["smugmug.images.get"](sessionid, albumid);
  }

  if(objectp(res))
    throw(Error.Generic("SmugMug error: " + res->fault_string + "\n"));
  else
  {
    return res[0];
  }
}

//!
mapping get_image_urls(int imageid, int|void templateid)
{
  if(!sessionid)
    throw(Error.Generic("SmugMug: not logged in.\n"));

  array args = ({});

  if(templateid)
    args += ({templateid});

  mixed res = 
  xmlrpc["smugmug.images.getURLs"](sessionid, imageid, @args);


  if(objectp(res))
    throw(Error.Generic("SmugMug error: " + res->fault_string + "\n"));
  else
  {
    return res[0];
  }
}

//!
mapping get_image_info(int imageid)
{
  if(!sessionid)
    throw(Error.Generic("SmugMug: not logged in.\n"));

  mixed res = 
  xmlrpc["smugmug.images.getInfo"](sessionid, imageid);

  if(objectp(res))
    throw(Error.Generic("SmugMug error: " + res->fault_string + "\n"));
  else
  {
    return res[0];
  }
}

//!
mapping get_image_exif(int imageid)
{
  if(!sessionid)
    throw(Error.Generic("SmugMug: not logged in.\n"));

  mixed res = 
  xmlrpc["smugmug.images.getEXIF"](sessionid, imageid);

  if(objectp(res))
    throw(Error.Generic("SmugMug error: " + res->fault_string + "\n"));
  else
  {
    return res[0];
  }
}

//!
int delete_image(int imageid)
{
  if(!sessionid)
    throw(Error.Generic("SmugMug: not logged in.\n"));

  mixed res = 
  xmlrpc["smugmug.images.delete"](sessionid, imageid);

  if(objectp(res))
    throw(Error.Generic("SmugMug error: " + res->fault_string + "\n"));
  else
  {
    return (res[0]=="SUCCESS"?1:0);
  }
}

//!
mapping get_image_stats(int imageid, int month, int year, int|void heavy)
{
  if(!sessionid)
    throw(Error.Generic("SmugMug: not logged in.\n"));

  object x;

  object  res = 
    xmlrpc["smugmug.albums.getStats"](sessionid, imageid, month, year);

  if(objectp(res))
    throw(Error.Generic("SmugMug error: " + res->fault_string + "\n"));
  else
  {
    return res[0];
  }
}

//!
int change_image_position(int imageid, int position)
{
  if(!sessionid)
    throw(Error.Generic("SmugMug: not logged in.\n"));

  mixed res = 
  xmlrpc["smugmug.images.changePosition"](sessionid, imageid, position);

  if(objectp(res))
    throw(Error.Generic("SmugMug error: " + res->fault_string + "\n"));
  else
  {
    return (res[0]);
  }
}

//! settings: mapping ([AlbumID, Caption, Keywords]);
int change_image_settings(int imageid, mapping settings)
{
  if(!sessionid)
    throw(Error.Generic("SmugMug: not logged in.\n"));

  mixed res = 
  xmlrpc["smugmug.images.changeSettings"](sessionid, imageid, settings);

  if(objectp(res))
    throw(Error.Generic("SmugMug error: " + res->fault_string + "\n"));
  else
  {
    return (res[0]);
  }
}


int upload_image(int albumid, string data, string|void filename, 
    string|void caption)
{

  if(!sessionid)
    throw(Error.Generic("SmugMug: not logged in.\n"));

  mapping args = ([]);

  if(caption) args->Caption = caption;
  args->ByteCount = sizeof(data);
  args->ResponseType = "XML-RPC";
  if(filename)
    args->FileName = filename;
  args->SessionID = sessionid;
  args->Data = (["data": data, "filename": filename]);
  string dta = post_url_data_mp("http" + (secure?"s":"") + "://" + UPLOAD_URL, 
                                 (["AlbumID": albumid ]) + args, ([]));

  werror("response: " + dta);

  return 1;
}


array search(string query)
{
   string q = "http://www.smugmug.com/hack/feed.mg?Type=search&Data=" + query + "&format=rss200";

   string r = Protocols.HTTP.get_url_data(q);

   if(!r) return ({});

   object d = Public.Web.RSS.parse(r);
   array res = ({});

   foreach(d->items;; object item)
   {
      res+=({item->data->guid[0]});
   }
 
   return res;
}

//! Similar to @[get_url], except that query variables is sent as a
//! POST request instead of a GET request.
static Protocols.HTTP.Query post_url_mp(string|Standards.URI url,
                mapping(string:int|string) query_variables,
                void|mapping(string:string|array(string)) request_headers,
                void|Protocols.HTTP.Query con)
{

  array f = ({});

  foreach(query_variables;string key;string|mapping value)
  {

     object m = MIME.Message();
     m->setdisp_param("name", key);

     if(mappingp(value))
     {
       m->setdisp_param("filename", value->filename);
       m->setdata((string)value->data);
     }
     else
       m->setdata((string)value);

     f+=({m});
  }

  object m = MIME.Message("", request_headers, f);  

    string data = m->getencoded( );

    if (m->body_parts) {
      m->type = "multipart";
      m->subtype = "form-data";
      if (!m->boundary) 
      {
        m->setboundary(MIME.generate_boundary());
      }
      data += "\r\n";
      foreach( m->body_parts, string body_part )
        data += "--"+m->boundary+"\r\n"+((string)body_part)+"\r\n";
      data += "--"+m->boundary+"--\r\n";
    }

//werror("data: %O\n", data);
//werror("headers: %O\n", m->headers);
  return Protocols.HTTP.do_method("POST", url, 0,
                   m->headers,
                   con,
                   data);
}

//! Similar to @[get_url_nice], except that query variables is sent as
//! a POST request instead of a GET request.
static array(string) post_url_nice_mp(string|Standards.URI url,
                            mapping(string:int|string) query_variables,
                            void|mapping(string:string|array(string)) request_headers,
                            void|Protocols.HTTP.Query con)
{
  Protocols.HTTP.Query c = post_url_mp(url, query_variables, request_headers, con);
  return c && ({ c->headers["content-type"], c->data() });
}

//! Similar to @[get_url_data], except that query variables is sent as
//! a POST request instead of a GET request.
static string post_url_data_mp(string|Standards.URI url,
                     mapping(string:int|string) query_variables,
                     void|mapping request_headers,
                     void|Protocols.HTTP.Query con)
{

  Protocols.HTTP.Query z = post_url_mp(url, query_variables, request_headers, con);
  return z && z->data();
}

