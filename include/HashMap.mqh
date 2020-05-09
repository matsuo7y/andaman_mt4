//+------------------------------------------------------------------+
//|                                                      HashMap.mqh |
//|                                     Copyright 2020, Yuki Matsuo. |
//+------------------------------------------------------------------+
#include <Object.mqh>
#include <Arrays\ArrayObj.mqh>

#define BUCKET_SIZE (128)

class CHashMapNode : public CObject
  {
public:
   int           m_key;
   CObject       *m_value;

                 CHashMapNode(int key, CObject *value);
                 ~CHashMapNode(void);
  };

CHashMapNode::CHashMapNode(int key, CObject *value) : m_key(key),
                                                      m_value(value)
  {
  }

CHashMapNode::~CHashMapNode(void)
  {
  }

class CHashMap : public CObject
  {
private:
   CArrayObj     *m_map[BUCKET_SIZE];

public:
                 CHashMap(void);
                 ~CHashMap(void);

   bool          Add(int key, CObject *value);
   CObject       *Get(int key);

   void          Clear();

protected:
   virtual int   Hash(int key);
  };

CHashMap::CHashMap(void)
  {
   for(int i=0; i<BUCKET_SIZE; i++) {
      m_map[i] = NULL;
   }
  }

CHashMap::~CHashMap(void)
  {
   Clear();
  }

bool CHashMap::Add(int key, CObject *value)
  {
   int bucket_key = Hash(key);

   CArrayObj *array = m_map[bucket_key];

   if(array == NULL) {
      array = new CArrayObj;
      m_map[bucket_key] = array;
   }

   for(int i=0; i<array.Total(); i++) {
      CHashMapNode *node = dynamic_cast<CHashMapNode*>(array.At(i));
      if(node.m_key == key)
         return(false);
   }

   return array.Add(new CHashMapNode(key, value));
  }

CObject* CHashMap::Get(int key)
  {
   int bucket_key = Hash(key);

   CArrayObj *array = m_map[bucket_key];
   if(array == NULL)
      return NULL;

   for(int i=0; i<array.Total(); i++) {
      CHashMapNode *node = dynamic_cast<CHashMapNode*>(array.At(i));
      if(node.m_key == key)
        return node.m_value;
   }
   return NULL;
  }

void CHashMap::Clear()
  {
   for(int i=0; i<BUCKET_SIZE; i++) {
      if(m_map[i] != NULL) {
         delete m_map[i];
         m_map[i] = NULL;
      }
   }
  }

int CHashMap::Hash(int key)
  {
   return key % BUCKET_SIZE;
  }
