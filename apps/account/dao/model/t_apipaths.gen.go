// Code generated by gorm.io/gen. DO NOT EDIT.
// Code generated by gorm.io/gen. DO NOT EDIT.
// Code generated by gorm.io/gen. DO NOT EDIT.

package model

const TableNameTApipath = "t_apipaths"

// TApipath mapped from table <t_apipaths>
type TApipath struct {
	ID       int64  `gorm:"column:id;type:bigint;primaryKey;autoIncrement:true" json:"id"`
	SvcName  string `gorm:"column:svc_name;type:text;comment:对外提供api服务的名称" json:"svc_name"`                  // 对外提供api服务的名称
	SvcAPI   string `gorm:"column:svc_api;type:text;comment:api path 名称" json:"svc_api"`                     // api path 名称
	Roles    string `gorm:"column:roles;type:text[];comment:RBAC权限的角色绑定，默认admin拥有，前端多选操作更新改集合" json:"roles"` // RBAC权限的角色绑定，默认admin拥有，前端多选操作更新改集合
	CreateAt int64  `gorm:"column:create_at;type:bigint" json:"create_at"`
	UpdateAt int64  `gorm:"column:update_at;type:bigint" json:"update_at"`
	DeleteAt int64  `gorm:"column:delete_at;type:bigint" json:"delete_at"`
}

// TableName TApipath's table name
func (*TApipath) TableName() string {
	return TableNameTApipath
}
