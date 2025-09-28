package app

import (
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func SetupAppRoutes(router *gin.Engine, db *gorm.DB) {
	apiGroup := router.Group("/api/v1")
	{
		SetupAuthAppRoutes(apiGroup, db)
		setupTopUpAppRoutes(apiGroup, db)
		setupAddressAppRoutes(apiGroup, db)
		SetupAfiliasiRoutes(apiGroup, db)
		SetupBankAccountRoutes(apiGroup, db)
		SetupCartRoutes(apiGroup, db)
		SetupPesananAppRoutes(apiGroup, db)
		setupPoinAppRoutes(apiGroup, db)
		setupProductAppRoutes(apiGroup, db)
		SetupFavoriteRoutes(apiGroup, db)
		setupProvinceCityAppRoutes(apiGroup, db)
		setupSettingAppRoutes(apiGroup, db)
	}
}
