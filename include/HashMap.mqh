//+------------------------------------------------------------------+
//|                                                      HashMap.mqh |
//|                                     Copyright 2020, Yuki Matsuo. |
//+------------------------------------------------------------------+
#include <Object.mqh>
#include <Arrays\ArrayObj.mqh>

#define BUCKET_SIZE (128)

class CHashMap : public CObject
  {
private:
   CArrayObj     *m_map[BUCKET_SIZE];

public:
                 CHashMap(void);
                 ~CHashMap(void);

   bool          Add(int key, CObject *value);
   void          DeleteBucket(int key);
   void          Shutdown();

protected:
   virtual int   Hash(int key);
  };

CHashMap::CHashMap(void) {
    for(int i=0; i<BUCKET_SIZE; i++) {
        m_map[i] = NULL;
    }
}

CHashMap::~CHashMap(void) {
   Shutdown();
}

bool CHashMap::Add(int key, CObject *value)
  {
   int bucket_key = Hash(key);

   CArrayObj *array = m_map[bucket_key];

   if(array == NULL) {
      array = new CArrayObj;
      array.FreeMode(false);
      m_map[bucket_key] = array;
   }

   return array.Add(value);
  }

void CHashMap::DeleteBucket(int key)
  {
   int bucket_key = Hash(key);

   if(m_map[bucket_key] == NULL)
      return;

   delete m_map[bucket_key];
  }

void CHashMap::Shutdown()
  {
   for(int i; i<BUCKET_SIZE; i++) {
      if(m_map[i] != NULL)
         delete m_map[i];
   }
  }

int CHashMap::Hash(int key)
  {
   return key % BUCKET_SIZE;
  }
