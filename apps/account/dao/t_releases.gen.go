// Code generated by gorm.io/gen. DO NOT EDIT.
// Code generated by gorm.io/gen. DO NOT EDIT.
// Code generated by gorm.io/gen. DO NOT EDIT.

package dao

import (
	"context"

	"gorm.io/gorm"
	"gorm.io/gorm/clause"
	"gorm.io/gorm/schema"

	"gorm.io/gen"
	"gorm.io/gen/field"

	"gorm.io/plugin/dbresolver"

	"code.pypygo.com/vertex/ollie/apps/account/dao/model"
)

func newTRelease(db *gorm.DB, opts ...gen.DOOption) tRelease {
	_tRelease := tRelease{}

	_tRelease.tReleaseDo.UseDB(db, opts...)
	_tRelease.tReleaseDo.UseModel(&model.TRelease{})

	tableName := _tRelease.tReleaseDo.TableName()
	_tRelease.ALL = field.NewAsterisk(tableName)
	_tRelease.ID = field.NewInt64(tableName, "id")
	_tRelease.Name = field.NewString(tableName, "name")
	_tRelease.Creator = field.NewString(tableName, "creator")
	_tRelease.FlowStatus = field.NewInt32(tableName, "flow_status")
	_tRelease.SchedWeight = field.NewInt32(tableName, "sched_weight")
	_tRelease.IsRunning = field.NewBool(tableName, "is_running")
	_tRelease.SelectedServiceVersionLists = field.NewString(tableName, "selected_service_version_lists")
	_tRelease.EnvType = field.NewInt32(tableName, "env_type")
	_tRelease.OperateType = field.NewString(tableName, "operate_type")
	_tRelease.CideployFaildCount = field.NewInt32(tableName, "cideploy_faild_count")
	_tRelease.CreateAt = field.NewInt64(tableName, "create_at")
	_tRelease.UpdateAt = field.NewInt64(tableName, "update_at")
	_tRelease.DeleteAt = field.NewInt64(tableName, "delete_at")

	_tRelease.fillFieldMap()

	return _tRelease
}

type tRelease struct {
	tReleaseDo

	ALL                         field.Asterisk
	ID                          field.Int64
	Name                        field.String // 可读的发布单名称，RFC3339命名
	Creator                     field.String // 发布单创建者
	FlowStatus                  field.Int32  // 最新流转状态
	SchedWeight                 field.Int32  // 调度权重值,高者优先
	IsRunning                   field.Bool   // 执行态状态
	SelectedServiceVersionLists field.String // 发布目标服务的json列集合
	EnvType                     field.Int32  // 发布目标环境，dev|prod
	OperateType                 field.String // 操作release的具体按钮动作需调度的类型绑定，init(默认)|primary(全量)|rollback(回滚)|quota(更新配置)|删除(delete)
	CideployFaildCount          field.Int32  // 最大部署调度重试次数，超过阈值不在调度，web前端按钮主动显式操作方式:删除|重试
	CreateAt                    field.Int64
	UpdateAt                    field.Int64
	DeleteAt                    field.Int64

	fieldMap map[string]field.Expr
}

func (t tRelease) Table(newTableName string) *tRelease {
	t.tReleaseDo.UseTable(newTableName)
	return t.updateTableName(newTableName)
}

func (t tRelease) As(alias string) *tRelease {
	t.tReleaseDo.DO = *(t.tReleaseDo.As(alias).(*gen.DO))
	return t.updateTableName(alias)
}

func (t *tRelease) updateTableName(table string) *tRelease {
	t.ALL = field.NewAsterisk(table)
	t.ID = field.NewInt64(table, "id")
	t.Name = field.NewString(table, "name")
	t.Creator = field.NewString(table, "creator")
	t.FlowStatus = field.NewInt32(table, "flow_status")
	t.SchedWeight = field.NewInt32(table, "sched_weight")
	t.IsRunning = field.NewBool(table, "is_running")
	t.SelectedServiceVersionLists = field.NewString(table, "selected_service_version_lists")
	t.EnvType = field.NewInt32(table, "env_type")
	t.OperateType = field.NewString(table, "operate_type")
	t.CideployFaildCount = field.NewInt32(table, "cideploy_faild_count")
	t.CreateAt = field.NewInt64(table, "create_at")
	t.UpdateAt = field.NewInt64(table, "update_at")
	t.DeleteAt = field.NewInt64(table, "delete_at")

	t.fillFieldMap()

	return t
}

func (t *tRelease) GetFieldByName(fieldName string) (field.OrderExpr, bool) {
	_f, ok := t.fieldMap[fieldName]
	if !ok || _f == nil {
		return nil, false
	}
	_oe, ok := _f.(field.OrderExpr)
	return _oe, ok
}

func (t *tRelease) fillFieldMap() {
	t.fieldMap = make(map[string]field.Expr, 13)
	t.fieldMap["id"] = t.ID
	t.fieldMap["name"] = t.Name
	t.fieldMap["creator"] = t.Creator
	t.fieldMap["flow_status"] = t.FlowStatus
	t.fieldMap["sched_weight"] = t.SchedWeight
	t.fieldMap["is_running"] = t.IsRunning
	t.fieldMap["selected_service_version_lists"] = t.SelectedServiceVersionLists
	t.fieldMap["env_type"] = t.EnvType
	t.fieldMap["operate_type"] = t.OperateType
	t.fieldMap["cideploy_faild_count"] = t.CideployFaildCount
	t.fieldMap["create_at"] = t.CreateAt
	t.fieldMap["update_at"] = t.UpdateAt
	t.fieldMap["delete_at"] = t.DeleteAt
}

func (t tRelease) clone(db *gorm.DB) tRelease {
	t.tReleaseDo.ReplaceConnPool(db.Statement.ConnPool)
	return t
}

func (t tRelease) replaceDB(db *gorm.DB) tRelease {
	t.tReleaseDo.ReplaceDB(db)
	return t
}

type tReleaseDo struct{ gen.DO }

type ITReleaseDo interface {
	gen.SubQuery
	Debug() ITReleaseDo
	WithContext(ctx context.Context) ITReleaseDo
	WithResult(fc func(tx gen.Dao)) gen.ResultInfo
	ReplaceDB(db *gorm.DB)
	ReadDB() ITReleaseDo
	WriteDB() ITReleaseDo
	As(alias string) gen.Dao
	Session(config *gorm.Session) ITReleaseDo
	Columns(cols ...field.Expr) gen.Columns
	Clauses(conds ...clause.Expression) ITReleaseDo
	Not(conds ...gen.Condition) ITReleaseDo
	Or(conds ...gen.Condition) ITReleaseDo
	Select(conds ...field.Expr) ITReleaseDo
	Where(conds ...gen.Condition) ITReleaseDo
	Order(conds ...field.Expr) ITReleaseDo
	Distinct(cols ...field.Expr) ITReleaseDo
	Omit(cols ...field.Expr) ITReleaseDo
	Join(table schema.Tabler, on ...field.Expr) ITReleaseDo
	LeftJoin(table schema.Tabler, on ...field.Expr) ITReleaseDo
	RightJoin(table schema.Tabler, on ...field.Expr) ITReleaseDo
	Group(cols ...field.Expr) ITReleaseDo
	Having(conds ...gen.Condition) ITReleaseDo
	Limit(limit int) ITReleaseDo
	Offset(offset int) ITReleaseDo
	Count() (count int64, err error)
	Scopes(funcs ...func(gen.Dao) gen.Dao) ITReleaseDo
	Unscoped() ITReleaseDo
	Create(values ...*model.TRelease) error
	CreateInBatches(values []*model.TRelease, batchSize int) error
	Save(values ...*model.TRelease) error
	First() (*model.TRelease, error)
	Take() (*model.TRelease, error)
	Last() (*model.TRelease, error)
	Find() ([]*model.TRelease, error)
	FindInBatch(batchSize int, fc func(tx gen.Dao, batch int) error) (results []*model.TRelease, err error)
	FindInBatches(result *[]*model.TRelease, batchSize int, fc func(tx gen.Dao, batch int) error) error
	Pluck(column field.Expr, dest interface{}) error
	Delete(...*model.TRelease) (info gen.ResultInfo, err error)
	Update(column field.Expr, value interface{}) (info gen.ResultInfo, err error)
	UpdateSimple(columns ...field.AssignExpr) (info gen.ResultInfo, err error)
	Updates(value interface{}) (info gen.ResultInfo, err error)
	UpdateColumn(column field.Expr, value interface{}) (info gen.ResultInfo, err error)
	UpdateColumnSimple(columns ...field.AssignExpr) (info gen.ResultInfo, err error)
	UpdateColumns(value interface{}) (info gen.ResultInfo, err error)
	UpdateFrom(q gen.SubQuery) gen.Dao
	Attrs(attrs ...field.AssignExpr) ITReleaseDo
	Assign(attrs ...field.AssignExpr) ITReleaseDo
	Joins(fields ...field.RelationField) ITReleaseDo
	Preload(fields ...field.RelationField) ITReleaseDo
	FirstOrInit() (*model.TRelease, error)
	FirstOrCreate() (*model.TRelease, error)
	FindByPage(offset int, limit int) (result []*model.TRelease, count int64, err error)
	ScanByPage(result interface{}, offset int, limit int) (count int64, err error)
	Scan(result interface{}) (err error)
	Returning(value interface{}, columns ...string) ITReleaseDo
	UnderlyingDB() *gorm.DB
	schema.Tabler
}

func (t tReleaseDo) Debug() ITReleaseDo {
	return t.withDO(t.DO.Debug())
}

func (t tReleaseDo) WithContext(ctx context.Context) ITReleaseDo {
	return t.withDO(t.DO.WithContext(ctx))
}

func (t tReleaseDo) ReadDB() ITReleaseDo {
	return t.Clauses(dbresolver.Read)
}

func (t tReleaseDo) WriteDB() ITReleaseDo {
	return t.Clauses(dbresolver.Write)
}

func (t tReleaseDo) Session(config *gorm.Session) ITReleaseDo {
	return t.withDO(t.DO.Session(config))
}

func (t tReleaseDo) Clauses(conds ...clause.Expression) ITReleaseDo {
	return t.withDO(t.DO.Clauses(conds...))
}

func (t tReleaseDo) Returning(value interface{}, columns ...string) ITReleaseDo {
	return t.withDO(t.DO.Returning(value, columns...))
}

func (t tReleaseDo) Not(conds ...gen.Condition) ITReleaseDo {
	return t.withDO(t.DO.Not(conds...))
}

func (t tReleaseDo) Or(conds ...gen.Condition) ITReleaseDo {
	return t.withDO(t.DO.Or(conds...))
}

func (t tReleaseDo) Select(conds ...field.Expr) ITReleaseDo {
	return t.withDO(t.DO.Select(conds...))
}

func (t tReleaseDo) Where(conds ...gen.Condition) ITReleaseDo {
	return t.withDO(t.DO.Where(conds...))
}

func (t tReleaseDo) Order(conds ...field.Expr) ITReleaseDo {
	return t.withDO(t.DO.Order(conds...))
}

func (t tReleaseDo) Distinct(cols ...field.Expr) ITReleaseDo {
	return t.withDO(t.DO.Distinct(cols...))
}

func (t tReleaseDo) Omit(cols ...field.Expr) ITReleaseDo {
	return t.withDO(t.DO.Omit(cols...))
}

func (t tReleaseDo) Join(table schema.Tabler, on ...field.Expr) ITReleaseDo {
	return t.withDO(t.DO.Join(table, on...))
}

func (t tReleaseDo) LeftJoin(table schema.Tabler, on ...field.Expr) ITReleaseDo {
	return t.withDO(t.DO.LeftJoin(table, on...))
}

func (t tReleaseDo) RightJoin(table schema.Tabler, on ...field.Expr) ITReleaseDo {
	return t.withDO(t.DO.RightJoin(table, on...))
}

func (t tReleaseDo) Group(cols ...field.Expr) ITReleaseDo {
	return t.withDO(t.DO.Group(cols...))
}

func (t tReleaseDo) Having(conds ...gen.Condition) ITReleaseDo {
	return t.withDO(t.DO.Having(conds...))
}

func (t tReleaseDo) Limit(limit int) ITReleaseDo {
	return t.withDO(t.DO.Limit(limit))
}

func (t tReleaseDo) Offset(offset int) ITReleaseDo {
	return t.withDO(t.DO.Offset(offset))
}

func (t tReleaseDo) Scopes(funcs ...func(gen.Dao) gen.Dao) ITReleaseDo {
	return t.withDO(t.DO.Scopes(funcs...))
}

func (t tReleaseDo) Unscoped() ITReleaseDo {
	return t.withDO(t.DO.Unscoped())
}

func (t tReleaseDo) Create(values ...*model.TRelease) error {
	if len(values) == 0 {
		return nil
	}
	return t.DO.Create(values)
}

func (t tReleaseDo) CreateInBatches(values []*model.TRelease, batchSize int) error {
	return t.DO.CreateInBatches(values, batchSize)
}

// Save : !!! underlying implementation is different with GORM
// The method is equivalent to executing the statement: db.Clauses(clause.OnConflict{UpdateAll: true}).Create(values)
func (t tReleaseDo) Save(values ...*model.TRelease) error {
	if len(values) == 0 {
		return nil
	}
	return t.DO.Save(values)
}

func (t tReleaseDo) First() (*model.TRelease, error) {
	if result, err := t.DO.First(); err != nil {
		return nil, err
	} else {
		return result.(*model.TRelease), nil
	}
}

func (t tReleaseDo) Take() (*model.TRelease, error) {
	if result, err := t.DO.Take(); err != nil {
		return nil, err
	} else {
		return result.(*model.TRelease), nil
	}
}

func (t tReleaseDo) Last() (*model.TRelease, error) {
	if result, err := t.DO.Last(); err != nil {
		return nil, err
	} else {
		return result.(*model.TRelease), nil
	}
}

func (t tReleaseDo) Find() ([]*model.TRelease, error) {
	result, err := t.DO.Find()
	return result.([]*model.TRelease), err
}

func (t tReleaseDo) FindInBatch(batchSize int, fc func(tx gen.Dao, batch int) error) (results []*model.TRelease, err error) {
	buf := make([]*model.TRelease, 0, batchSize)
	err = t.DO.FindInBatches(&buf, batchSize, func(tx gen.Dao, batch int) error {
		defer func() { results = append(results, buf...) }()
		return fc(tx, batch)
	})
	return results, err
}

func (t tReleaseDo) FindInBatches(result *[]*model.TRelease, batchSize int, fc func(tx gen.Dao, batch int) error) error {
	return t.DO.FindInBatches(result, batchSize, fc)
}

func (t tReleaseDo) Attrs(attrs ...field.AssignExpr) ITReleaseDo {
	return t.withDO(t.DO.Attrs(attrs...))
}

func (t tReleaseDo) Assign(attrs ...field.AssignExpr) ITReleaseDo {
	return t.withDO(t.DO.Assign(attrs...))
}

func (t tReleaseDo) Joins(fields ...field.RelationField) ITReleaseDo {
	for _, _f := range fields {
		t = *t.withDO(t.DO.Joins(_f))
	}
	return &t
}

func (t tReleaseDo) Preload(fields ...field.RelationField) ITReleaseDo {
	for _, _f := range fields {
		t = *t.withDO(t.DO.Preload(_f))
	}
	return &t
}

func (t tReleaseDo) FirstOrInit() (*model.TRelease, error) {
	if result, err := t.DO.FirstOrInit(); err != nil {
		return nil, err
	} else {
		return result.(*model.TRelease), nil
	}
}

func (t tReleaseDo) FirstOrCreate() (*model.TRelease, error) {
	if result, err := t.DO.FirstOrCreate(); err != nil {
		return nil, err
	} else {
		return result.(*model.TRelease), nil
	}
}

func (t tReleaseDo) FindByPage(offset int, limit int) (result []*model.TRelease, count int64, err error) {
	result, err = t.Offset(offset).Limit(limit).Find()
	if err != nil {
		return
	}

	if size := len(result); 0 < limit && 0 < size && size < limit {
		count = int64(size + offset)
		return
	}

	count, err = t.Offset(-1).Limit(-1).Count()
	return
}

func (t tReleaseDo) ScanByPage(result interface{}, offset int, limit int) (count int64, err error) {
	count, err = t.Count()
	if err != nil {
		return
	}

	err = t.Offset(offset).Limit(limit).Scan(result)
	return
}

func (t tReleaseDo) Scan(result interface{}) (err error) {
	return t.DO.Scan(result)
}

func (t tReleaseDo) Delete(models ...*model.TRelease) (result gen.ResultInfo, err error) {
	return t.DO.Delete(models)
}

func (t *tReleaseDo) withDO(do gen.Dao) *tReleaseDo {
	t.DO = *do.(*gen.DO)
	return t
}
